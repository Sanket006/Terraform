# Security Group for ALB
resource "aws_security_group" "alb_sg" {
    name        = "alb_security_group"
    description = "Security group for Application Load Balancer"
    vpc_id      = aws_vpc.main.id

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
    security_groups    = [aws_security_group.alb_sg.id]
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
    vpc_id   = aws_vpc.main.id
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

# Security Group for ASG Instances
resource "aws_security_group" "ec2_sg" {
  name        = "asg_security_group"
  description = "Security group for ASG instances"
  vpc_id      = aws_vpc.main.id

  # Inbound rules
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [ aws_security_group.alb_sg.id ]
  } 
    # Outbound rules
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
            Name = "asg_security_group"
        }
}

# Launch Template for ASG
resource "aws_launch_template" "asg_lt" {
  name_prefix   = "asg-launch-template"
  image_id      = "ami-0c55b159cbfafe1f0" # Example AMI ID, replace with your desired AMI
  instance_type = "t2.micro"
  
  network_interfaces {
    security_groups = [ aws_security_group.ec2_sg ]
  }

  user_data = base64encode(<<-EOF
                #!/bin/bash
                yum update -y
                yum install -y httpd
                systemctl start httpd
                systemctl enable httpd
                echo "<h1>Welcome to ASG Instance</h1>" > /var/www/html/index.html
                EOF
    )

    tag_specifications {
        resource_type = "instance"

        tags = {
            Name = "ASG-Instance"
            env  = "dev"
        }
    }
}
# Auto Scaling Group
resource "aws_autoscaling_group" "my_asg" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = [aws_subnet.public_subnet.id]
  
  launch_template {
    id      = aws_launch_template.asg_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.my_tg.arn]

  tag {
    key                 = "Name"
    value               = "ASG-Instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "env"
    value               = "dev"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Scaling Policy
resource "aws_autoscaling_policy" "cpu_policy" {
  name                   = "cpu-scaling-policy"
  autoscaling_group_name = aws_autoscaling_group.my_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}