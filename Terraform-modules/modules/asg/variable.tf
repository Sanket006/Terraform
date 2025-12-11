variable "launch_template_name" {
  default = "asg-launch-template"
}

variable "ami_id" {
  default = "ami-0c55b159cbfafe1f0" # Example AMI ID, replace with your desired AMI
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "my-key-pair" # Replace with your key pair name
}

variable "user_data_script" {
  default = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y nginx
              echo "<h1>Welcome to Auto Scaling Group $(hostname)</h1>" > /var/www/html/index.html
              systemctl start nginx
              systemctl enable nginx
    EOF
}

variable "env" {
  default = "dev"
}

variable "desired_capacity" {
  default = 2
}

variable "max_size" {
  default = 3
}

variable "min_size" {
  default = 1
}

variable "policy_name" {
  default = "cpu-scaling-policy"
}

variable "policy_type" {
  default = "TargetTrackingScaling"
}

variable "predefined_metric_type" {
  default = "ASGAverageCPUUtilization"
}

variable "target_value" {
  default = 50.0
}