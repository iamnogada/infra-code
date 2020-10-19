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

resource "azurerm_network_interface" "op_vm-nic" {
  name                = "${var.op_vm_name}-nic"
  location            = var.location
  resource_group_name = var.resourcegroup

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.op_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address ="10.242.16.4"
  }
}

resource "azurerm_linux_virtual_machine" "opvm" {
  name                = var.op_vm_name
  resource_group_name = var.resourcegroup
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
}
resource "azurerm_network_interface" "vm-nic" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resourcegroup

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address ="10.242.16.70"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vm_name
  resource_group_name = var.resourcegroup
  location            = var.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.vm-nic.id,
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
}