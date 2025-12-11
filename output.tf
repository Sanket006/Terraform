output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

output "public_route_table_id" {
  value = aws_route_table.public_rt.id
}

output "public_route_table_association_id" {
  value = aws_route_table_association.public_assoc.id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}

output "eip_nat_id" {
  value = aws_eip.nat_eip.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat_gw.id
}

output "private_route_table_id" {
  value = aws_route_table.private_rt.id
}

output "private_route_table_association_id" {
  value = aws_route_table_association.private_assoc.id
}

output "security_group_id" {
  value = aws_security_group.my_sg.id
}

output "ec2_instance_id" {
  value = aws_instance.my_ec2.id
}

output "ec2_instance_public_ip" {
  value = aws_instance.my_ec2.public_ip
}

output "ec2_instance_public_dns" {
  value = aws_instance.my_ec2.public_dns
}
