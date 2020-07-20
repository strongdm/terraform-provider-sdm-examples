variable "server_name" {
  default = "windows-server"
}
#################
# Create RSA Key Pair
#################
resource "tls_private_key" "windows_server" {
  # This resource is not recommended for production environements
  algorithm = "RSA"
  rsa_bits  = 2048
}
resource "aws_key_pair" "windows_key" {
  key_name   = "windows_key"
  public_key = tls_private_key.windows_server.public_key_openssh
}
#################
# Deploy strongDM relay to private subnet
#################
module "sdm_gateway" {
  source = "github.com/peteroneilljr/terraform_aws_strongdm_gateways"

  sdm_node_name = "aws-windows-env"

  deploy_vpc_id    = module.vpc.vpc_id
  relay_subnet_ids = [module.vpc.private_subnets[0]]

  dev_mode = true
  tags     = var.default_tags
}
#################
# Deploy Windows Server Instance
#################
resource "aws_instance" "windows_server" {
  ami           = data.aws_ami.windows_server.image_id
  instance_type = "t3.medium"

  subnet_id              = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.windows_server.id]

  get_password_data = true
  key_name          = aws_key_pair.windows_key.key_name
  # This key is used to encrypt the windows password

  user_data = local.windows_user_data
  # User data script makes NLA optional, and installs strongDM client 

  tags = merge({ Name = var.server_name }, var.default_tags, )
}
locals {
  windows_user_data = <<USERDATA
<powershell>
# Allow authentication method to be negotiated between server and client
Write-Output "Allow authentication method to be negotiated between server and client"
New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "SecurityLayer" -Value "1" -PropertyType DWORD -Force | Out-Null

# Disable NLA for RDP  
Write-Output "Disable NLA for RDP"
New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value "0" -PropertyType DWORD -Force | Out-Null

# Install firefox
Invoke-WebRequest -Uri "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=en-GB" -Outfile C:\Users\Administrator\Desktop\firefox.msi
Start-Process msiexec.exe -Wait -ArgumentList '/I C:\Users\Administrator\Desktop\firefox.msi /quiet'

# Install SDM Client
[Net.ServicePointManager]::SecurityProtocol +='tls12'
Invoke-WebRequest -Uri "https://app.strongdm.com/downloads/client/win32" -Outfile "C:\Users\Administrator\Desktop\sdm_installer.exe"
Start-Process "C:\Users\Administrator\Desktop\sdm_installer.exe" -ArgumentList "/q" -Wait
# For service installer use https://app.strongdm.com/releases/cli/windows
</powershell>
<persist>true</persist>
USERDATA
}
data "aws_ami" "windows_server" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["Windows_Server-2016-English*"]
  }
}
#################
# Security Group allowing port 3389
#################
resource "aws_security_group" "windows_server" {
  name        = var.server_name
  description = var.server_name
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({ Name = var.server_name }, var.default_tags, )
}
#################
# Register server with strongDM
#################
resource "sdm_resource" "windows_server" {
  rdp {
    name     = "terraform-${var.server_name}"
    hostname = aws_instance.windows_server.private_ip
    port     = 3389
    username = "Administrator"
    password = rsadecrypt(aws_instance.windows_server.password_data, tls_private_key.windows_server.private_key_pem)
    tags     = var.default_tags
  }
}
resource "sdm_role_grant" "windows_server" {
  role_id     = sdm_role.windows_server.id
  resource_id = sdm_resource.windows_server.id
}
resource "sdm_role" "windows_server" {
  name = "Terraform Windows Servers Role"
}
#################
# Outputs
#################
output "windows_password" {
  value     = rsadecrypt(aws_instance.windows_server.password_data, tls_private_key.windows_server.private_key_pem)
  sensitive = true
}
