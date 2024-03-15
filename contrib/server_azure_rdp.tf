#################
# Variables 
#################
variable "server_name" {
  default = "windows-server"
}
variable "sdm_relay" {
  default = "sdm-relay"
}
variable "windows_username" {
  default = "strongdm"
}
resource "random_password" "windows_server" {
  length  = 25
  special = false
}
variable "sdm_linux_username" {
  default = "sdm"
}
#################
# strongDM account creation
#################
resource "sdm_account" "windows_user" {
  user {
    first_name = "strongDM"
    last_name  = "Windows"
    email      = "user@email.com"
  }
}
resource "sdm_account_attachment" "windows_user" {
  account_id = sdm_account.windows_user.id
  role_id    = sdm_role.windows_server.id
}
resource "sdm_role" "windows_server" {
  name = "Terraform Azure Role"
}
#################
# strongDM Relay
#################
resource "sdm_node" "azure_relay" {
  relay {
    name = "azure-${var.sdm_relay}"
  }
}
resource "sdm_resource" "azure_relay" {
  ssh {
    name     = sdm_node.azure_relay.relay.0.name
    username = var.sdm_linux_username
    hostname = azurerm_network_interface.sdm_relay.private_ip_address
    port     = 22
  }
}
resource "sdm_role_grant" "azure_relay" {
  role_id     = sdm_role.windows_server.id
  resource_id = sdm_resource.azure_relay.id
}
#################
# strongDM Windows Server
#################
resource "sdm_resource" "windows_server" {
  rdp {
    name     = "azure-${var.server_name}"
    hostname = azurerm_network_interface.windows_server.private_ip_address
    port     = 3389
    username = var.windows_username
    password = random_password.windows_server.result
    tags     = var.default_tags
  }
}
resource "sdm_role_grant" "windows_server" {
  role_id     = sdm_role.windows_server.id
  resource_id = sdm_resource.windows_server.id
}
#################
# Azure Resource Group
#################
resource "azurerm_resource_group" "sdm_group" {
  name     = "strongdm-resource-group"
  location = "West US"
}
#################
# Azure Private network
#################
resource "azurerm_virtual_network" "private_network" {
  name                = "private-network"
  resource_group_name = azurerm_resource_group.sdm_group.name
  location            = azurerm_resource_group.sdm_group.location
  address_space       = ["10.8.0.0/16"]
}
resource "azurerm_subnet" "private_subnet" {
  name                 = "${var.server_name}-private-subnet"
  resource_group_name  = azurerm_resource_group.sdm_group.name
  virtual_network_name = azurerm_virtual_network.private_network.name
  address_prefix       = "10.8.3.0/24"
}
resource "azurerm_network_interface" "sdm_relay" {
  name                = "${var.sdm_relay}-nic"
  location            = azurerm_resource_group.sdm_group.location
  resource_group_name = azurerm_resource_group.sdm_group.name

  ip_configuration {
    name                          = var.sdm_relay
    subnet_id                     = azurerm_subnet.private_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "windows_server" {
  name                = "${var.server_name}-nic"
  location            = azurerm_resource_group.sdm_group.location
  resource_group_name = azurerm_resource_group.sdm_group.name

  ip_configuration {
    name                          = var.server_name
    subnet_id                     = azurerm_subnet.private_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
#################
# Deploy strongDM relay
#################
resource "azurerm_virtual_machine" "sdm_relay" {
  name                  = var.sdm_relay
  location              = azurerm_resource_group.sdm_group.location
  resource_group_name   = azurerm_resource_group.sdm_group.name
  network_interface_ids = [azurerm_network_interface.sdm_relay.id]
  vm_size               = "Standard_B1s"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name          = var.sdm_relay
    create_option = "FromImage"
  }
  os_profile {
    computer_name  = var.sdm_relay
    admin_username = var.sdm_linux_username
    custom_data    = local.sdm_relay_config
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.sdm_linux_username}/.ssh/authorized_keys"
      key_data = sdm_resource.azure_relay.ssh.0.public_key
    }
  }
  tags = var.default_tags
}
locals {
  sdm_relay_config = <<RELAYCONFIG
#cloud-config
# Creates sdm user
users:
  - default
  - name: ${var.sdm_linux_username}
    gecos: strongDM
    ssh_authorized_keys:
    - ssh-rsa ${sdm_resource.azure_relay.ssh.0.public_key}
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
# Install unzip & curl
packages:
- curl
- unzip
runcmd:
# download and extract sdm binary
- 'curl -J -O -L https://app.strongdm.com/releases/cli/linux && unzip /sdmcli* && rm /sdmcli*'
# install sdm relay
- '/sdm install --user "${var.sdm_linux_username}" --relay --token="${sdm_node.azure_relay.relay.0.token}"'
RELAYCONFIG
}
#################
# Deploy Windows Server Instance
#################
resource "azurerm_virtual_machine" "windows_server" {
  name                  = var.server_name
  location              = azurerm_resource_group.sdm_group.location
  resource_group_name   = azurerm_resource_group.sdm_group.name
  network_interface_ids = [azurerm_network_interface.windows_server.id]
  vm_size               = "Standard_B2s"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true


  storage_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "rs5-pro"
    version   = "latest"
  }

  storage_os_disk {
    name          = var.server_name
    create_option = "FromImage"
  }
  os_profile {
    computer_name  = var.server_name
    admin_username = var.windows_username
    admin_password = random_password.windows_server.result
  }
  os_profile_windows_config {
    enable_automatic_upgrades = true
    provision_vm_agent        = true
  }
  tags = var.default_tags
}

#################
# Outputs
#################
output "windows_password" {
  value     = random_password.windows_server.result
  sensitive = true
}