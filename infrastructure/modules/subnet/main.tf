variable name { type = string }
variable rg-name { type = string }
variable vnet-name { type = string }
variable cidr { type = list(string) }

resource "azurerm_subnet" "subnet" {
  name                 = "${var.name}-001-subnet"
  resource_group_name  = var.rg-name
  virtual_network_name = var.vnet-name
  address_prefixes     = var.cidr
}

output "id" {
  value = azurerm_subnet.subnet.id
}

output "name" {
  value = azurerm_subnet.subnet.name
}
