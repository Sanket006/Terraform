# Launch Template for Auto Scaling Group
resource "aws_launch_template" "asg_lt" {
  name_prefix   = var.launch_template_name
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  user_data = var.user_data_script

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.launch_template_name}-instance"
      env  = var.env
    }
  }
  
}

# Auto Scaling Group
resource "aws_autoscaling_group" "my_asg" {
  desired_capacity     = var.desired_capacity
  max_size             = var.max_size
  min_size             = var.min_size
  vpc_zone_identifier  = [aws_subnet.public_subnet.id]
  
  launch_template {
    id      = aws_launch_template.asg_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.launch_template_name}-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "env"
    value               = var.env
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Scaling Policy
resource "aws_autoscaling_policy" "cpu_policy" {
  name                   = var.policy_name
  autoscaling_group_name = aws_autoscaling_group.my_asg.name
  policy_type            = var.policy_type

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.predefined_metric_type
    }
    target_value = var.target_value
  }
}