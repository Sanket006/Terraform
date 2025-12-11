variable "vpc_name" {
  default     = "my-vpc"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.1.24"
}

variable "private_subnet_cidr" {
  default = "10.0.2.0/24"
}

