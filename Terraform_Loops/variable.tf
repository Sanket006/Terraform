variable "ami_id" {
  default = "ami-02b8269d5e85954ef"
}

variable "instance_types" {
  default = {
    "dev"  = "t3.micro"
    "prod" = "c7i-flex.large"
    "test" = "t3.small"
  }
}