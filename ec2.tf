provider "aws" {
  region = var.region
}

# Ec2 instance
resource "aws_instance" "my_ec2" {
  ami           = var.ami
  instance_type = var.instance_type

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y nginx
              echo "Hello, World!" > /var/www/html/index.html
              systemctl start nginx
              systemctl enable nginx
              EOF
              
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  tags = {
    Name = "my-ec2"
    env = var.env
  }
  
}

