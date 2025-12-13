provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "my_instance" {
#   count         = 3
  ami           = var.ami_id
  for_each      = var.instance_types
  instance_type = each.value
  
  tags = {
    Name = "Instance-${each.key}"
    Env  = each.key
  }
}