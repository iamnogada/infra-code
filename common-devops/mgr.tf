########################################################################
##  variables
########################################################################
variable mgr {
  type = object({
    name = string
    ip   = string
    size = string
    cidr = list(string)
  })
  default = {
    name = "mgr"
    ip   = "10.242.16.36"
    size = "Standard_D2s_v3"
    cidr = ["10.242.16.32/27"]
  }
}

########################################################################
##  mgr : subnet, resource-group, network-interface, vm
##  import udr
########################################################################



module "mgr" {
  source = "../modules/subnet"
  name   = "${module.const.long-name}-${var.mgr.name}" #"skgc-vrd-prod-mgr-koce"
  rg     = module.const.rg
  vnet   = module.const.vnet
  cidr   = var.mgr.cidr

}

resource "azurerm_resource_group" "mgr" {
  name     = "${module.const.long-name}-${var.mgr.name}-rg"
  location = module.const.location
  tags     = module.const.tags
}
resource "azurerm_public_ip" "mgr" {
  name                = "AZ${var.mgr.name}-pip"
  resource_group_name = azurerm_resource_group.mgr.name
  location            = azurerm_resource_group.mgr.location
  allocation_method   = "Dynamic"
  domain_name_label   = "skgcvrd${var.mgr.name}"

  tags = module.const.tags
}

resource "azurerm_network_interface" "mgr" {
  name                = "AZ${var.mgr.name}-nic"
  resource_group_name = azurerm_resource_group.mgr.name
  location            = azurerm_resource_group.mgr.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.mgr.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.mgr.ip
    public_ip_address_id          = azurerm_public_ip.mgr.id
  }
  depends_on = [module.mgr]
  tags       = module.const.tags
}
resource "azurerm_linux_virtual_machine" "mgr" {
  name                = "AZ${var.mgr.name}"
  resource_group_name = azurerm_resource_group.mgr.name
  location            = azurerm_resource_group.mgr.location
  size                = var.mgr.size
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.mgr.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("../id_rsa.pub")
  }

  os_disk {
    name                 = "AZ${var.mgr.name}-osdisk-001"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  depends_on = [azurerm_network_interface.mgr]
  tags       = module.const.tags
}
