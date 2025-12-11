provider "aws" {
  region = "ap-south-1"
}

# ---- DEFAULT VPC & DEFAULT SUBNETS ----
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

locals {
  public_subnets = [
    aws_default_subnet.a.id,
    aws_default_subnet.b.id,
    aws_default_subnet.c.id
  ]
}

# ---- SECURITY GROUPS ----
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

# ---- ALB ----
resource "aws_lb" "flipkart_alb" {
  name               = "flipkart-alb"
  load_balancer_type = "application"
  subnets            = local.public_subnets
  security_groups    = [aws_security_group.alb_sg.id]
}

# ---- TARGET GROUPS ----
resource "aws_lb_target_group" "tg_home" {
  name     = "tg-home"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id

  health_check {
    path = "/"
  }
}

resource "aws_lb_target_group" "tg_products" {
  name     = "tg-products"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id

  health_check {
    path = "/"
  }
}

resource "aws_lb_target_group" "tg_cart" {
  name     = "tg-cart"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id

  health_check {
    path = "/"
  }
}

# ---- LISTENER ----
resource "aws_lb_listener" "flipkart_listener" {
  load_balancer_arn = aws_lb.flipkart_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_home.arn
  }
}

# ---- LISTENER RULES ----
resource "aws_lb_listener_rule" "products_rule" {
  listener_arn = aws_lb_listener.flipkart_listener.arn
  priority     = 10

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

resource "aws_lb_listener_rule" "cart_rule" {
  listener_arn = aws_lb_listener.flipkart_listener.arn
  priority     = 20

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

# ---- EC2: HOME SERVICE ----
resource "aws_instance" "home_service" {
  count         = 2
  ami           = "ami-0cda377a1b884a1bc"
  instance_type = "t2.micro"
  subnet_id     = local.public_subnets[count.index]
  security_groups = [aws_security_group.ec2_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y nginx
    echo "<h1>Welcome to Flipkart Home Page - $(hostname)</h1>" > /var/www/html/index.html
    systemctl enable nginx
    systemctl start nginx
  EOF
}

# ---- EC2: PRODUCT SERVICE ----
resource "aws_instance" "product_service" {
  count         = 2
  ami           = "ami-0cda377a1b884a1bc"
  instance_type = "t2.micro"
  subnet_id     = local.public_subnets[count.index]
  security_groups = [aws_security_group.ec2_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y nginx
    echo "<h1>Welcome to Flipkart Products Page - $(hostname)</h1>" > /var/www/html/index.html
    systemctl enable nginx
    systemctl start nginx
  EOF
}

# ---- EC2: CART SERVICE ----
resource "aws_instance" "cart_service" {
  count         = 2
  ami           = "ami-0cda377a1b884a1bc"
  instance_type = "t2.micro"
  subnet_id     = local.public_subnets[count.index]
  security_groups = [aws_security_group.ec2_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y nginx
    echo "<h1>Welcome to Flipkart Cart Page - $(hostname)</h1>" > /var/www/html/index.html
    systemctl enable nginx
    systemctl start nginx
  EOF
}

# ---- ATTACH INSTANCES TO TARGET GROUPS ----
resource "aws_lb_target_group_attachment" "attach_home" {
  count             = 2
  target_group_arn  = aws_lb_target_group.tg_home.arn
  target_id         = aws_instance.home_service[count.index].id
  port              = 80
}

resource "aws_lb_target_group_attachment" "attach_products" {
  count             = 2
  target_group_arn  = aws_lb_target_group.tg_products.arn
  target_id         = aws_instance.product_service[count.index].id
  port              = 80
}

resource "aws_lb_target_group_attachment" "attach_cart" {
  count             = 2
  target_group_arn  = aws_lb_target_group.tg_cart.arn
  target_id         = aws_instance.cart_service[count.index].id
  port              = 80
}

# ---- OUTPUT ----
output "flipkart_url" {
  value = aws_lb.flipkart_alb.dns_name
}
