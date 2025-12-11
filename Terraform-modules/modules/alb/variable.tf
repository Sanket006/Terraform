variable "alb_sg_name" {
  default = "alb_security_group"
}

variable "alb_sg_description" {
  default = "Security group for ALB"
}

variable "alb_name" {
  default = "my-alb"
}

variable "alb_type" {
  default = "application"
}

variable "target_group_name" {
  default = "my-target-group"
}

variable "target_group_port" {
  default = 80
}

variable "target_group_protocol" {
  default = "HTTP"
}

variable "target_type" {
  default = "instance"
}

variable "listener_port" {
  default = 80
}

variable "listener_protocol" {
  default = "HTTP"
}

variable "default_action_type" {
  default = "forward"
}

