#  variables
variable devops {
  type = object({
    name = string
    ip   = string
    size = string
    cidr = list(string)
  })
  default = {
    name = "devops"
    ip   = "10.242.16.4"
    size = "Standard_D2s_v3"
    cidr = ["10.242.16.0/27"]
  }
}
variable acr {
  type = object({
    name = string
  })
  default = {
    name = "acr"
  }
}

########################################################################
##  devops : subnet, resource-group, network-interface, vm
########################################################################

######## import udr
data "azurerm_route_table" "udr" {
  name                = module.const.udr
  resource_group_name = module.const.rg
}

######## subnet
module "devops" {
  source = "../modules/subnet"
  name   = "${module.const.long-name}-${var.devops.name}" #"skgc-vrd-prod-devops-koce"
  rg     = module.const.rg
  vnet   = module.const.vnet
  cidr   = var.devops.cidr

}

######## assign hub routing rule
resource "azurerm_subnet_route_table_association" "udr-association" {
  subnet_id      = module.devops.id
  route_table_id = data.azurerm_route_table.udr.id

  depends_on = [module.devops]
}

######## container registry resource
resource "azurerm_resource_group" "acr" {
  name     = "${module.const.long-name}-${var.acr.name}-rg"
  location = module.const.location
  tags     = module.const.tags
}
resource "azurerm_container_registry" "acr" {
  name                = "${module.const.owner}registry"
  resource_group_name = azurerm_resource_group.acr.name
  location            = azurerm_resource_group.acr.location
  sku                 = "Premium"
  admin_enabled       = true
}

######## devops resource
resource "azurerm_resource_group" "devops" {
  name     = "${module.const.long-name}-${var.devops.name}-rg"
  location = module.const.location
  tags     = module.const.tags
}
resource "azurerm_network_interface" "devops" {
  name                = "AZ${var.devops.name}-nic"
  resource_group_name = azurerm_resource_group.devops.name
  location            = azurerm_resource_group.devops.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.devops.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.devops.ip
  }
  depends_on = [module.devops]
  tags       = module.const.tags
}
resource "azurerm_linux_virtual_machine" "devops" {
  name                = "AZ${var.devops.name}"
  resource_group_name = azurerm_resource_group.devops.name
  location            = azurerm_resource_group.devops.location
  size                = var.devops.size
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.devops.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("../id_rsa.pub")
  }

  os_disk {
    name                 = "AZ${var.devops.name}-osdisk-001"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 100
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  depends_on = [azurerm_network_interface.devops]
  tags       = module.const.tags
}
