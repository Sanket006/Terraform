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
   ami = "ami-02b8269d5e85954ef"
   instance_type = "t3.small"
    tags = {
        Name = "MyFirstInstance"
        env = "prod"
    }
}
