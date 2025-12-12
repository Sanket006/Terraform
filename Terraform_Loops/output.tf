output "instance_public_ips" {
  value = [for n in aws_instance.my_instance : n.public_ip]
  
}