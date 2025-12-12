provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [var.vpc_sg_id]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("C:/Users/Lenovo/Downloads/ajaymumbaikey.pem") # Ensure the path to your private key is correct OR for ec2 instance you should copy key to /root/ and provide path : ~/keyname.pem
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "index.html" # Ensure this file exists in the same directory OR for ec2 instance path : ./index.html
    destination = "/home/ubuntu/index.html"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install apache2 -y",
      # "sudo sed -i \"s/\\${hostname}/$(hostname)/g\" /home/ubuntu/index.html", # Optional: To replace a placeholder in index.html with the actual hostname
      "sudo mv /home/ubuntu/index.html /var/www/html/index.html",
      "sudo systemctl restart apache2"
    ]
  }

  provisioner "local-exec" {
    command = "echo The server IP is ${self.public_ip}"
  }

  tags = {
    Name = var.name_tag

  }
}
