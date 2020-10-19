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


resource "azurerm_storage_account" "skgcvrddevportalstorage" {
  name                     = "skgcvrddevportalstorage"
  location                 = var.location
  resource_group_name      = var.resourcegroup
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access       = false

  tags = {
    "Application or Service Name" = "vrd"
    "Environment"                 = "dev"
    "Operated By"                 = "skcc-cloudops"
    "Owner"                       = "skgc"
  }
}
