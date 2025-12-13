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

resource "aws_lb" "flipkart_alb" {
  name               = "flipkart-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]

  subnets = [
    aws_default_subnet.a.id,
    aws_default_subnet.b.id,
    aws_default_subnet.c.id
  ]
}

resource "aws_lb_target_group" "flipkart_tg" {
  name     = "flipkart-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.flipkart_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.flipkart_tg.arn
  }
}

resource "aws_launch_template" "flipkart_lt" {
  name_prefix   = "flipkart-lt"
  image_id      = "ami-0cda377a1b884a1bc" # Ubuntu 22.04 (Mumbai)
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(<<EOF
#!/bin/bash
apt update -y
apt install nginx -y

mkdir -p /var/www/html/electronics
mkdir -p /var/www/html/fashion
mkdir -p /var/www/html/grocery

echo "<h1>Flipkart Home - $(hostname)</h1>" > /var/www/html/index.html
echo "<h1>Electronics Page - $(hostname)</h1>" > /var/www/html/electronics/index.html
echo "<h1>Fashion Page - $(hostname)</h1>" > /var/www/html/fashion/index.html
echo "<h1>Grocery Page - $(hostname)</h1>" > /var/www/html/grocery/index.html

systemctl restart nginx
systemctl enable nginx
EOF
  )
}

resource "aws_autoscaling_group" "flipkart_asg" {
  name                = "flipkart_asg"
  min_size            = 2
  max_size            = 4
  desired_capacity    = 2
  vpc_zone_identifier = [
    aws_default_subnet.a.id,
    aws_default_subnet.b.id,
    aws_default_subnet.c.id
  ]

  target_group_arns = [aws_lb_target_group.flipkart_tg.arn]

  launch_template {
    id      = aws_launch_template.flipkart_lt.id
    version = "$Latest"
  }
}

output "flipkart_url" {
  value = aws_lb.flipkart_alb.dns_name
}
