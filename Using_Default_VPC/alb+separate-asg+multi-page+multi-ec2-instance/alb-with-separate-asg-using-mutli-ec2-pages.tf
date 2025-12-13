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

resource "aws_lb" "alb" {
  name               = "flipkart-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]

  subnets = [
    aws_default_subnet.a.id,
    aws_default_subnet.b.id,
    aws_default_subnet.c.id
  ]
}

resource "aws_lb_target_group" "home_tg" {
  name     = "tg-home"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id
}

resource "aws_lb_target_group" "electronics_tg" {
  name     = "tg-electronics"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id
}

resource "aws_lb_target_group" "fashion_tg" {
  name     = "tg-fashion"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id
}

resource "aws_lb_target_group" "grocery_tg" {
  name     = "tg-grocery"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.home_tg.arn
  }
}

resource "aws_lb_listener_rule" "electronics" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.electronics_tg.arn
  }

  condition {
    path_pattern { values = ["/electronics/*"] }
  }
}

resource "aws_lb_listener_rule" "fashion" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fashion_tg.arn
  }

  condition {
    path_pattern { values = ["/fashion/*"] }
  }
}

resource "aws_lb_listener_rule" "grocery" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grocery_tg.arn
  }

  condition {
    path_pattern { values = ["/grocery/*"] }
  }
}

resource "aws_launch_template" "home_lt" {
  name_prefix   = "home-lt"
  image_id      = "ami-0cda377a1b884a1bc"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(<<EOF
#!/bin/bash
apt update -y
apt install nginx -y
echo "<h1>Flipkart Home - $(hostname)</h1>" > /var/www/html/index.html
systemctl start nginx
EOF
  )
}

resource "aws_launch_template" "electronics_lt" {
  name_prefix   = "electronics-lt"
  image_id      = "ami-0cda377a1b884a1bc"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(<<EOF
#!/bin/bash
apt update -y
apt install nginx -y
echo "<h1>Flipkart Electronic Page - $(hostname)</h1>" > /var/www/html/index.html
systemctl start nginx
EOF
  )
}

resource "aws_launch_template" "fashion_lt" {
  name_prefix   = "fashion-lt"
  image_id      = "ami-0cda377a1b884a1bc"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(<<EOF
#!/bin/bash
apt update -y
apt install nginx -y
echo "<h1>Flipkart Fashion Page - $(hostname)</h1>" > /var/www/html/index.html
systemctl start nginx
EOF
  )
}

resource "aws_launch_template" "grocery_lt" {
  name_prefix   = "grocery-lt"
  image_id      = "ami-0cda377a1b884a1bc"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(<<EOF
#!/bin/bash
apt update -y
apt install nginx -y
echo "<h1>Flipkart Grocery Page - $(hostname)</h1>" > /var/www/html/index.html
systemctl start nginx
EOF
  )
}

resource "aws_autoscaling_group" "home_asg" {
  desired_capacity = 2
  min_size         = 2
  max_size         = 4

  vpc_zone_identifier = [
    aws_default_subnet.a.id,
    aws_default_subnet.b.id,
    aws_default_subnet.c.id
  ]

  target_group_arns = [aws_lb_target_group.home_tg.arn]

  launch_template {
    id      = aws_launch_template.home_lt.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_group" "electronics_asg" {
  desired_capacity = 2
  min_size         = 2
  max_size         = 4

  vpc_zone_identifier = [
    aws_default_subnet.a.id,
    aws_default_subnet.b.id,
    aws_default_subnet.c.id
  ]

  target_group_arns = [aws_lb_target_group.electronics_tg.arn]

  launch_template {
    id      = aws_launch_template.electronics_lt.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_group" "fashion_asg" {
  desired_capacity = 2
  min_size         = 2
  max_size         = 4

  vpc_zone_identifier = [
    aws_default_subnet.a.id,
    aws_default_subnet.b.id,
    aws_default_subnet.c.id
  ]

  target_group_arns = [aws_lb_target_group.fashion_tg.arn]

  launch_template {
    id      = aws_launch_template.fashion_lt.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_group" "grocery_asg" {
  desired_capacity = 2
  min_size         = 2
  max_size         = 4

  vpc_zone_identifier = [
    aws_default_subnet.a.id,
    aws_default_subnet.b.id,
    aws_default_subnet.c.id
  ]

  target_group_arns = [aws_lb_target_group.grocery_tg.arn]

  launch_template {
    id      = aws_launch_template.grocery_lt.id
    version = "$Latest"
  }
}

output "flipkart_url" {
  value = aws_lb.alb.dns_name
}
