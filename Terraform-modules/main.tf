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

  region        = var.region
  cluster_name  = "demo-eks-cluster"
  vpc_cidr      = "10.0.0.0/16"
  subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]

  instance_type = "c7i-flex.large"
  desired_size  = 2
  min_size      = 1
  max_size      = 3
}

