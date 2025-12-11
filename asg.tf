#  Auto Scaling Group with Launch Template, Scaling Policy, and CloudWatch Alarms
provider "aws" {
  region = "ap-south-1"
}

# Launch Template for Auto Scaling Group
resource "aws_launch_template" "asg_lt" {
  name_prefix   = "asg-launch-template"
  image_id      = "ami-0c55b159cbfafe1f0" # Example AMI ID, replace with your desired AMI
  instance_type = "t2.micro"
  key_name = "my-key-pair" # Replace with your key pair name
  
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  user_data = base64decode(<<-EOF
              #!/bin/bash
              apt update -y
              apt install -y nginx
              systemctl start nginx 
              echo "<h1>Welcome to Auto Scaling Group $(hostname)</h1>" > /var/www/html/index.html
              systemctl enable nginx
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

# CloudWatch Alarm for Scaling
resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
    alarm_name          = "high-cpu-alarm"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods  = 2
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = 300
    statistic           = "Average"
    threshold           = 70.0
    
    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.my_asg.name
    }
    
    alarm_actions = [aws_autoscaling_policy.cpu_policy.arn]
}

# CloudWatch Alarm for Scaling Down
resource "aws_cloudwatch_metric_alarm" "low_cpu_alarm" {
    alarm_name          = "low-cpu-alarm"
    comparison_operator = "LessThanThreshold"
    evaluation_periods  = 2
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = 300
    statistic           = "Average"
    threshold           = 30.0
    
    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.my_asg.name
    }
    
    alarm_actions = [aws_autoscaling_policy.cpu_policy.arn]
}