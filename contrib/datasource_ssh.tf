resource "aws_instance" "ubuntu" {
  instance_type = "t3.micro"
  key_name      = var.key_name
  ami           = data.aws_ami.ubuntu.image_id
}

resource "sdm_resource" "ubuntu" {
  ssh {
    name     = var.server_name
    username = "ubuntu"
    hostname = aws_instance.ubuntu.public_ip
    port     = 22
  }
  provisioner "remote-exec" {
     inline = [
      "echo '${self.ssh.0.public_key}' >> ~/.ssh/authorized_keys",
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.path_to_private_key)
      host        = aws_instance.ubuntu.public_ip
    }
  }
}