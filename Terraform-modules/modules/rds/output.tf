output "rds_instance_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.my_rds.endpoint
}

output "rds_instance_id" {
  description = "The ID of the RDS instance"
  value       = aws_db_instance.my_rds.id
}

output "rds_security_group_id" {
  description = "The ID of the RDS security group"
  value       = aws_security_group.rds_sg.id
}

output "rds_db_subnet_group_name" {
  description = "The name of the RDS DB subnet group"
  value       = aws_db_subnet_group.db_subnet_group.name
}
