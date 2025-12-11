terraform {
  backend "s3" {
    bucket = "amazon-s3-bucket-backend-tfstate"
    key    = "terraform.tfstate"
    region = "ap-south-1"
    
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "my_instacne" {
   ami = var.ami
   instance_type = var.instance_type
    tags = {
        Name = "MyFirstInstance"
        env = var.env
    }
}
