provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = "ajaymumbaikey"
  vpc_security_group_ids = ["sg-0783875e9e5d14881"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("C:/Users/Lenovo/Downloads/ajaymumbaikey.pem")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "index.html"
    destination = "/home/ubuntu/index.html"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install apache2 -y",
      "sudo mkdir -p /var/www/html/",
      "sudo mv /home/ubuntu/index.html /var/www/html/index.html",
      "sudo chown www-data:www-data /var/www/html/index.html",
      "sudo systemctl restart apache2"
    ]
  }

  provisioner "local-exec" {
    command = "echo The server IP is ${self.public_ip}"
  }


  tags = {
    name = var.name_tag
  }
}
