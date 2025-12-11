output "asg_name" {
  description = "The name of the Auto Scaling Group"
  value       = aws_autoscaling_group.my_asg.name
}

output "launch_template_id" {
  description = "The ID of the Launch Template"
  value       = aws_launch_template.asg_lt.id
}

output "scaling_policy_arn" {
  description = "The ARN of the Auto Scaling Policy"
  value       = aws_autoscaling_policy.cpu_policy.arn
}

