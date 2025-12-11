variable "ami" {
  default = "ami-0c55b159cbfafe1f0" # Example AMI ID for Ubuntu in us-east-1
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "my-key-pair"
}

variable "user_data_script" {
  default = <<-EOF
              #!/bin/bash
              apt-update -y
              apt-install nginx -y
              echo "Hello, World from $(hostname)" > /var/www/html/index.html
              systemctl start nginx
              systemctl enable nginx
              EOF
}

variable "env" {
  default = "dev"
}
