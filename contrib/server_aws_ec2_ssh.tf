#################
# Create RSA Key Pair
#################
resource "tls_private_key" "ssh_server" {
  # This resource is not recommended for production environements
  algorithm = "RSA"
  rsa_bits  = 2048
}
resource "aws_key_pair" "server_key" {
  key_name   = "server_key"
  public_key = tls_private_key.ssh_server.public_key_openssh
}

#################
# Grab latest ubuntu AMI ID
#################
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "state"
    values = ["available"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic*"]
  }

}

#################
# Create EC2 instance
#################
resource "aws_instance" "ubuntu" {
  instance_type = "t3.micro"
  key_name      = aws_key_pair.server_key.key_name
  ami           = data.aws_ami.ubuntu.image_id
}

#################
# Add server to strongDM
#################
resource "sdm_resource" "ubuntu" {
  ssh {
    name     = var.server_name
    username = "ubuntu"
    hostname = aws_instance.ubuntu.public_ip
    port     = 22
  }
  # Provisioner to add strongDM public key to server.
  provisioner "remote-exec" {
     inline = [
      "echo '${self.ssh.0.public_key}' >> ~/.ssh/authorized_keys",
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.ssh_server.private_key_pem
      host        = aws_instance.ubuntu.public_ip
    }
  }
}