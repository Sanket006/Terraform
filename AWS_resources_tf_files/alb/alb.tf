# Terraform configuration for Application Load Balancer (ALB)
provider "aws" {
  region = "ap-south-1"
}

# Security Group for ALB
resource "aws_security_group" "alb_sg" {
    name        = "alb_security_group"
    description = "Security group for ALB"
    vpc_id      = aws_vpc.my_vpc.id
    # Inbound rules
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    # Outbound rules
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "alb_security_group"
    }
}

# Application Load Balancer
resource "aws_lb" "my_alb" {
    name               = "my-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.my_sg.id]
    subnets            = [aws_subnet.public_subnet.id]
    
    tags = {
        Name = "my-alb"
    }
}

# Target Group for ALB
resource "aws_lb_target_group" "my_tg" {
    name     = "my-target-group"
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.my-vpc.id
    target_type = "instance"

    health_check {
        path                = "/"
        protocol            = "HTTP"
    }

    tags = {
        Name = "my-target-group"
    }
}

# Listener for ALB
resource "aws_lb_listener" "my_listener" {
    load_balancer_arn = aws_lb.my_alb.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.my_tg.arn
    }
}

# Attach EC2 instance to Target Group
resource "aws_lb_target_group_attachment" "my_tg_attachment" {
    target_group_arn = aws_lb_target_group.my_tg.arn
    target_id        = aws_instance.my_ec2.id
    port             = 80
}