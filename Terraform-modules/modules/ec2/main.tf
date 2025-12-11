# Ec2 instance
resource "aws_instance" "my_ec2" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = var.user_data_script
              
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  tags = {
    Name = "${var.env}-ec2-instance"
    env = var.env
  }
  
}