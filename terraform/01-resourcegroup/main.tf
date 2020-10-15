# Configure the Azure provider
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

resource "azurerm_resource_group" "vrd-resource-group" {
  for_each = var.resourcegroups
  
  name = each.key
  location = var.location
  tags = {
    "Application or Service Name" = "vrd"
    "Environment" = each.value
    "Operated By" = "skcc-cloudops"
    "Owner" = "skgc"
  }
}
