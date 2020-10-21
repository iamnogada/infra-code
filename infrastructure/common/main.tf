terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  features {}
}

variable location {
  type    = string
  default = "koreacentral"
}

variable devops-subnet {
  type = object({
    name = string
    cidr = list(string)
  })
  default = {
    name = "devops"
    cidr = ["10.242.16.32/27"]
  }
}
variable mgr-subnet {
  type = object({
    name = string
    cidr = list(string)
  })
  default = {
    name = "mgr"
    cidr = ["10.242.16.0/27"]
  }
}

locals {
  owner   = "skgc"
  service = "vrd"
  env     = "prod"
  center  = "koce"
  tags = {
    "Application or Service Name" = local.service
    "Environment"                 = local.env
    "Operated By"                 = "skcc-cloudops"
    "Owner"                       = local.owner
  }
}

########################################################################
##  network resource with skgc-vrd-prod-koce-network-rg
########################################################################

module "devops-subnet" {
  source    = "../modules/subnet"
  name      = "${local.owner}-${local.service}-${local.env}-${local.center}-${var.devops-subnet.name}" #"skgc-vrd-prod-devops-koce"
  rg-name   = "skgc-vrd-prod-koce-network-rg"
  vnet-name = "vrd-001-vnet"
  cidr      = var.devops-subnet.cidr

}

module "mgr-subnet" {
  source    = "../modules/subnet"
  name      = "${local.owner}-${local.service}-${local.env}-${local.center}-${var.mgr-subnet.name}" #"skgc-vrd-prod-devops-koce"
  rg-name   = "skgc-vrd-prod-koce-network-rg"
  vnet-name = "vrd-001-vnet"
  cidr      = var.mgr-subnet.cidr

}

module "udr" {
  source   = "../modules/routetable"
  name     = "${local.owner}-${local.service}-${local.env}-${local.center}" #"skgc-vrd-prod-devops-koce"
  location = var.location
  rg-name  = "skgc-vrd-prod-koce-network-rg"

  tags = local.tags
}

resource "azurerm_subnet_route_table_association" "udr-association" {
  subnet_id      = module.devops-subnet.id
  route_table_id = module.udr.id

  depends_on = [module.udr, module.devops-subnet]
}

########################################################################
##  mgr vm 
########################################################################
variable mgr-size {
    type = string
    default = "Standard_D2s_v3"
}
variable mgr-ip {
    type = string
    default ="10.242.16.4"
}
variable mgr-name {
    type = string
    default = "SkgcVrdMgr"
}


resource "azurerm_resource_group" "mgr-rg" {
  name = "${local.owner}-${local.service}-${local.env}-${local.center}-mgr-rg"
  location = var.location
  tags = local.tags
}
resource "azurerm_public_ip" "mgr-pip" {
  name                = "Az${var.mgr-name}-pip"
  resource_group_name = azurerm_resource_group.mgr-rg.name
  location            = azurerm_resource_group.mgr-rg.location
  allocation_method   = "Dynamic"
  domain_name_label   = "skgcvrdmgr"

  tags = local.tags
}
resource "azurerm_network_interface" "mgr-nic" {
  name                = "Az${var.mgr-name}-nic"
  resource_group_name = azurerm_resource_group.mgr-rg.name
  location            = azurerm_resource_group.mgr-rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.mgr-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address = var.mgr-ip
    public_ip_address_id          = azurerm_public_ip.mgr-pip.id
  }
  depends_on = [azurerm_public_ip.mgr-pip,module.mgr-subnet]
  tags = local.tags
}
resource "azurerm_linux_virtual_machine" "mgr-vm" {
  name                = "Az${var.mgr-name}"
  resource_group_name = azurerm_resource_group.mgr-rg.name
  location            = azurerm_resource_group.mgr-rg.location
  size                = var.mgr-size
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.mgr-nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("../id_rsa.pub")
  }

  os_disk {
    name = "Az${var.mgr-name}-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  depends_on = [azurerm_network_interface.mgr-nic]
  tags = local.tags
}


########################################################################
##  devops vm 
########################################################################
variable devops-size {
    type = string
    default = "Standard_D2s_v3"
}
variable devops-ip {
    type = string
    default ="10.242.16.36"
}
variable devops-name {
    type = string
    default = "SkgcVrdDevops"
}


resource "azurerm_resource_group" "devops-rg" {
  name = "${local.owner}-${local.service}-${local.env}-${local.center}-devops-rg"
  location = var.location
  tags = local.tags
}
resource "azurerm_network_interface" "devops-nic" {
  name                = "Az${var.devops-name}-nic"
  resource_group_name = azurerm_resource_group.devops-rg.name
  location            = azurerm_resource_group.devops-rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.devops-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address = var.devops-ip
  }
  depends_on = [module.devops-subnet]
  tags = local.tags
}
resource "azurerm_linux_virtual_machine" "devops-vm" {
  name                = "Az${var.devops-name}"
  resource_group_name = azurerm_resource_group.devops-rg.name
  location            = azurerm_resource_group.devops-rg.location
  size                = var.devops-size
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.devops-nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("../id_rsa.pub")
  }

  os_disk {
    name = "Az${var.devops-name}-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb = 100
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  depends_on = [azurerm_network_interface.devops-nic]
  tags = local.tags
}