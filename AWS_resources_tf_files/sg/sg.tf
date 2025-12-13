provider "aws" {
  region = var.region
}

# Security Group Resource
resource "aws_security_group" "my_sg" {
  name        = "my_security_group"
  description = "Security group for my EC2 instance"
  vpc_id      = aws_vpc.main.id

# Inbound rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
        Name = "my_security_group"
    }
}