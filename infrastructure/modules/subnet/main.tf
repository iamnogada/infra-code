variable name { type = string }
variable rg { type = string }
variable vnet { type = string }
variable cidr { type = list(string) }

resource "azurerm_subnet" "subnet" {
  name                 = "${var.name}-001-subnet"
  resource_group_name  = var.rg
  virtual_network_name = var.vnet
  address_prefixes     = var.cidr
}

output "id" {
  value = azurerm_subnet.subnet.id
}

output "name" {
  value = azurerm_subnet.subnet.name
}
