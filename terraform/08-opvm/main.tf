terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

# resource "azurerm_public_ip" "op_vm_pip" {
#   name                    = "op_vm_pip"
#   location            = var.location
#   resource_group_name = var.resourcegroup
#   allocation_method       = "Dynamic"
#   idle_timeout_in_minutes = 30

#   tags = {
#     "Application or Service Name" = "vrd"
#     "Environment"                 = "prod"
#     "Operated By"                 = "skcc-cloudops"
#     "Owner"                       = "skgc"
#   }
# }
resource "azurerm_network_interface" "op_vm-nic" {
  name                = "${var.op_vm_name}-nic"
  location            = var.location
  resource_group_name = "skgc-vrd-prod-koce-network-rg"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.op_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address ="10.242.16.70"
    public_ip_address_id          = "/subscriptions/2dbedacf-40ac-4b61-8bdc-a3025e767aee/resourceGroups/skgc-vrd-prod-koce-network-rg/providers/Microsoft.Network/publicIPAddresses/AZvrdbastion001-ip"
  }
  tags = {
    "Application or Service Name" = "vrd"
    "Environment"                 = "prod"
    "Operated By"                 = "skcc-cloudops"
    "Owner"                       = "skgc"
  }
}

resource "azurerm_linux_virtual_machine" "opvm" {
  name                = var.op_vm_name
  resource_group_name = "skgc-vrd-prod-koce-network-rg"
  location            = var.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.op_vm-nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("../id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  tags = {
    "Application or Service Name" = "vrd"
    "Environment"                 = "prod"
    "Operated By"                 = "skcc-cloudops"
    "Owner"                       = "skgc"
  }
}
resource "azurerm_network_interface" "devops_vm-nic" {
  name                = "${var.devops_vm_name}-nic"
  location            = var.location
  resource_group_name = var.devops_resourcegroup

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.devops_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address ="10.242.16.4"
  }
  tags = {
    "Application or Service Name" = "vrd"
    "Environment"                 = "prod"
    "Operated By"                 = "skcc-cloudops"
    "Owner"                       = "skgc"
  }
}

resource "azurerm_linux_virtual_machine" "devops_vm" {
  name                = var.devops_vm_name
  resource_group_name = var.devops_resourcegroup
  location            = var.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.devops_vm-nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("../id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  tags = {
    "Application or Service Name" = "vrd"
    "Environment"                 = "prod"
    "Operated By"                 = "skcc-cloudops"
    "Owner"                       = "skgc"
  }
}