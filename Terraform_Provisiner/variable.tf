variable "aws_region" {
  default = "ap-south-1"
}

variable "ami_id" {
  default = "ami-02b8269d5e85954ef"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "key_name" {
  default = "ajaymumbaikey"
}

variable "name_tag" {
  default = "Terraform-Web-Server"
}

variable "vpc_sg_id" {
  default = "sg-0783875e9e5d14881"
}
