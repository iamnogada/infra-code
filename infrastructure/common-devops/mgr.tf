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
    ip = "10.242.16.36"
    size = "Standard_D2s_v3"    
    cidr = ["10.242.16.32/27"]
  }
}

########################################################################
##  mgr : subnet, resource-group, network-interface, vm
##  import udr
########################################################################



module "mgr-subnet" {
  source    = "../modules/subnet"
  name      = "${local.owner}-${local.service}-${local.env}-${local.center}-${var.mgr.name}" #"skgc-vrd-prod-mgr-koce"
  rg-name   = var.nw-rg-name
  vnet-name = var.vnet-name
  cidr      = var.mgr.cidr

}

resource "azurerm_resource_group" "mgr-rg" {
  name     = "${local.owner}-${local.service}-${local.env}-${local.center}-${var.mgr.name}-rg"
  location = var.location
  tags     = local.tags
}
resource "azurerm_public_ip" "mgr-pip" {
  name                = "Az${var.mgr.name}-pip"
  resource_group_name = azurerm_resource_group.mgr-rg.name
  location            = azurerm_resource_group.mgr-rg.location
  allocation_method   = "Dynamic"
  domain_name_label   = "skgcvrd${var.mgr.name}"

  tags = local.tags
}

resource "azurerm_network_interface" "mgr-nic" {
  name                = "Az${var.mgr.name}-nic"
  resource_group_name = azurerm_resource_group.mgr-rg.name
  location            = azurerm_resource_group.mgr-rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.mgr-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.mgr.ip
    public_ip_address_id          = azurerm_public_ip.mgr-pip.id
  }
  depends_on = [module.mgr-subnet]
  tags       = local.tags
}
resource "azurerm_linux_virtual_machine" "mgr-vm" {
  name                = "Az${var.mgr.name}"
  resource_group_name = azurerm_resource_group.mgr-rg.name
  location            = azurerm_resource_group.mgr-rg.location
  size                = var.mgr.size
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.mgr-nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("../id_rsa.pub")
  }

  os_disk {
    name                 = "Az${var.mgr.name}-osdisk"
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
  tags       = local.tags
}
