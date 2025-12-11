provider "aws" {
  region = "ap-south-1"
}

# default VPC
resource "aws_default_vpc" "default" {}

resource "aws_default_subnet" "a" {
  availability_zone = "ap-south-1a"
}

resource "aws_default_subnet" "b" {
  availability_zone = "ap-south-1b"
}

resource "aws_default_subnet" "c" {
  availability_zone = "ap-south-1c"
}

# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name   = "flipkart-alb-sg"
  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for EC2 Instances
resource "aws_security_group" "ec2_sg" {
  name   = "flipkart-ec2-sg"
  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Application Load Balancer
resource "aws_lb" "flipkart_alb" {
  name               = "flipkart-alb"
  load_balancer_type = "application"

  subnets = [
    aws_default_subnet.a.id,
    aws_default_subnet.b.id,
    aws_default_subnet.c.id,
  ]

  security_groups = [aws_security_group.alb_sg.id]
}

# Target Group for Home Page
resource "aws_lb_target_group" "tg_home" {
  name     = "tg-home"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id

  health_check {
    path = "/"
  }
}

# Target Group for Products Page
resource "aws_lb_target_group" "tg_products" {
  name     = "tg-products"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id
  
  health_check {
    path = "/"
  }
}

# Target Group for Cart Page
resource "aws_lb_target_group" "tg_cart" {
  name     = "tg-cart"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id

  health_check {
    path = "/"
  }
}

# Listener for ALB
resource "aws_lb_listener" "flipkart_listener" {
  load_balancer_arn = aws_lb.flipkart_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_home.arn
  }
}

# Listener Rule for Home Page
resource "aws_lb_listener_rule" "home_rule" {
  listener_arn = aws_lb_listener.flipkart_listener.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_home.arn
  }

  condition {
    path_pattern {
      values = ["/home/*"]
    }
  }
}

# Listener Rule for Products Page
resource "aws_lb_listener_rule" "products_rule" {
  listener_arn = aws_lb_listener.flipkart_listener.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_products.arn
  }

  condition {
    path_pattern {
      values = ["/products/*"]
    }
  }
}

# Listener Rule for Cart Page
resource "aws_lb_listener_rule" "cart_rule" {
  listener_arn = aws_lb_listener.flipkart_listener.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_cart.arn
  }

  condition {
    path_pattern {
      values = ["/cart/*"]
    }
  }
}

# EC2 Instance for Home Page
resource "aws_instance" "home_service" {
  ami                    = "ami-0cda377a1b884a1bc"
  instance_type          = "t2.micro"
  subnet_id              = aws_default_subnet.a.id
  security_groups        = [aws_security_group.ec2_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y nginx
    echo "<h1>Welcome to Flipkart Home Page $(hostname)</h1>" > /var/www/html/index.html
    systemctl start nginx
    systemctl enable nginx
  EOF
}

# EC2 Instance for Products Page
resource "aws_instance" "product_service" {
  ami                    = "ami-0cda377a1b884a1bc"
  instance_type          = "t2.micro"
  subnet_id              = aws_default_subnet.b.id
  security_groups        = [aws_security_group.ec2_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y nginx
    echo "<h1>Flipkart Product Service $(hostname)</h1>" > /var/www/html/index.html
    systemctl start nginx
    systemctl enable nginx
  EOF
}

# EC2 Instance for Cart Page
resource "aws_instance" "cart_service" {
  ami                    = "ami-0cda377a1b884a1bc"
  instance_type          = "t2.micro"
  subnet_id              = aws_default_subnet.c.id
  security_groups        = [aws_security_group.ec2_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y nginx
    echo "<h1>Flipkart Cart Service $(hostname)</h1>" > /var/www/html/index.html
    systemctl start nginx
    systemctl enable nginx
  EOF
}

# Attach EC2 Instances to Target Groups
resource "aws_lb_target_group_attachment" "attach_home" {
  target_group_arn = aws_lb_target_group.tg_home.arn
  target_id        = aws_instance.home_service.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach_products" {
  target_group_arn = aws_lb_target_group.tg_products.arn
  target_id        = aws_instance.product_service.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach_cart" {
  target_group_arn = aws_lb_target_group.tg_cart.arn
  target_id        = aws_instance.cart_service.id
  port             = 80
}

# Output the ALB DNS Name
output "flipkart_url" {
  value = aws_lb.flipkart_alb.dns_name
}
