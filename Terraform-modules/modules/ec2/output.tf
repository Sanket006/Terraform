output "name" {
  value = aws_instance.my_ec2.id
}

output "public_ip" {
  value = aws_instance.my_ec2.public_ip
}

output "public_dns" {
  value = aws_instance.my_ec2.public_dns
}
