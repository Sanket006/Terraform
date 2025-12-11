provider "aws" {
  region = "ap-south-1"
}

module "vpc" {
  source = "./modules/vpc"

}

module "sg" {
  source = "./modules/sg"

}

module "ec2" {
  source = "./modules/ec2"

}

module "alb" {
  source = "./modules/alb"
  
}

module "asg" {
  source = "./modules/asg"

}

module "rds" {
  source = "./modules/rds"
  
}

module "eks" {
  source = "./modules/eks"

}

