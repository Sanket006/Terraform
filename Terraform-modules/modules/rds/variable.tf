variable "project" {
  default = "my-terraform-project"
}

variable "db_subnet_group_name" {
  default = "my-db-subnet-group"
}

variable "allowed_cidr_blocks" {
    default = "10.0.2.0/24"
}

variable "rds_sg_name" {
  default = "rds-security-group"
}

variable "description" {
  default = "Allow DB access"
}

variable "db_name" {
  default = "mydbinstance"
}

variable "engine_name" {
  default = "mysql"
}

variable "engine_version" {
  default = "8.0"
}

variable "instance_class" {
  default = "db.t3.micro"
}

variable "storage_type" {
  default = "gp2"
}

variable "allocated_storage" {
  default = 20
}

variable "username" {
  default = "admin"
}

variable "password" {
  default = "redhat@123"
}

variable "db_port" {
  default = 3306
}

variable "parameter_group_name" {
  default = "default.mysql8.0"
}

