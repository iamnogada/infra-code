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

# import udr

module "devops-subnet" {
  source    = "../modules/subnet"
  name      = "${local.owner}-${local.service}-${local.env}-${local.center}-${var.devops.name}" #"skgc-vrd-prod-devops-koce"
  rg-name   = var.nw-rg-name
  vnet-name = var.vnet-name
  cidr      = var.devops.cidr

}

data "azurerm_route_table" "udr" {
  name                = var.udr-name
  resource_group_name = var.nw-rg-name
}

# assign hub routing rule
resource "azurerm_subnet_route_table_association" "udr-association" {
  subnet_id      = module.devops-subnet.id
  route_table_id = data.azurerm_route_table.udr.id

  depends_on = [module.devops-subnet]
}
#container registry
resource "azurerm_resource_group" "acr-rg" {
  name     = "${local.owner}-${local.service}-${local.env}-${local.center}-${var.acr.name}-rg"
  location = var.location
  tags     = local.tags
}

resource "azurerm_container_registry" "acr" {
  name                = "${local.owner}${local.service}"
  resource_group_name = azurerm_resource_group.acr-rg.name
  location            = azurerm_resource_group.acr-rg.location
  sku                 = "Premium"
  admin_enabled       = true
}
# devops
resource "azurerm_resource_group" "devops-rg" {
  name     = "${local.owner}-${local.service}-${local.env}-${local.center}-${var.devops.name}-rg"
  location = var.location
  tags     = local.tags
}
resource "azurerm_network_interface" "devops-nic" {
  name                = "Az${var.devops.name}-nic"
  resource_group_name = azurerm_resource_group.devops-rg.name
  location            = azurerm_resource_group.devops-rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.devops-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.devops.ip
  }
  depends_on = [module.devops-subnet]
  tags       = local.tags
}
resource "azurerm_linux_virtual_machine" "devops-vm" {
  name                = "Az${var.devops.name}"
  resource_group_name = azurerm_resource_group.devops-rg.name
  location            = azurerm_resource_group.devops-rg.location
  size                = var.devops.size
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.devops-nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("../id_rsa.pub")
  }

  os_disk {
    name                 = "Az${var.devops.name}-osdisk"
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
  depends_on = [azurerm_network_interface.devops-nic]
  tags       = local.tags
}
