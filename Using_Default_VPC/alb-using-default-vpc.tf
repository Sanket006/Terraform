# Terraform/alb-using-default-vpc.tf

provider "aws" {
  region = "ap-south-1"
}

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
  name   = "alb-sg"
  vpc_id = aws_default_vpc.default.id

  ingress {
    description = "Allow HTTP"
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

  tags = {
    Name = "alb-sg"
  }
}

# Security Group for EC2 Instances
resource "aws_security_group" "ec2_sg" {
  name   = "ec2-sg"
  vpc_id = aws_default_vpc.default.id

  ingress {
    description = "Allow ALB → EC2 traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}

# Application Load Balancer
resource "aws_lb" "my_alb" {
  name               = "my-default-vpc-alb"
  load_balancer_type = "application"

  subnets = [
    aws_default_subnet.a.id,
    aws_default_subnet.b.id,
    aws_default_subnet.c.id,
  ]

  security_groups = [aws_security_group.alb_sg.id]

  tags = {
    Name = "my-default-vpc-alb"
  }
}

# Target Group for ALB
resource "aws_lb_target_group" "tg" {
  name     = "my-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "my-tg"
  }
}

# Listener for ALB
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# EC2 Instance
resource "aws_instance" "web" {
  ami                    = "ami-123456789abcdef0"  # Replace with a valid AMI ID for ap-south-1
  instance_type          = "t2.micro"
  subnet_id              = aws_default_subnet.a.id
  security_groups        = [aws_security_group.ec2_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y nginx
              echo "<h1>EC2 behind ALB - Hello $(hostname)</h1>" > /var/www/html/index.html
              systemctl start nginx
              systemctl enable nginx
              EOF

    tags = {
      Name = "ALB-EC2-Instance"
    }
}

# Attach EC2 instance to Target Group
resource "aws_lb_target_group_attachment" "tg_attachment" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.web.id
  port             = 80
}

output "alb_dns" {
  value = aws_lb.my_alb.dns_name
}