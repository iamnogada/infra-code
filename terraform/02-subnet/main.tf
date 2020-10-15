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

resource "azurerm_subnet" "vrd_subnet" {
  count                = length(var.vrd_subnets)
  name                 = var.vrd_subnets[count.index].name
  resource_group_name  = var.default_resourcegroup
  virtual_network_name = var.default_vnet
  address_prefixes     = var.vrd_subnets[count.index].cidr

  #   delegation {
  #     name = "acctestdelegation"

  #     service_delegation {
  #       name    = "Microsoft.ContainerInstance/containerGroups"
  #       actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
  #     }
  #   }
}

resource "azurerm_subnet_route_table_association" "vrd_subnet_udr" {
  count          = length(var.vrd_subnets)
  subnet_id      = azurerm_subnet.vrd_subnet[count.index].id
  route_table_id = var.default_route_id
}
