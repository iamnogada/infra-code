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


resource "azurerm_mariadb_server" "skgv-vrd-dev-dbms" {
  name                = "skgv-vrd-dev-dbms"
  location            = var.location
  resource_group_name = var.resourcegroup

  administrator_login          = "dbadmin"
  administrator_login_password = "tnwpql12#$"

  sku_name   = "GP_Gen5_2"
  storage_mb = 5120
  version    = "10.3"

  auto_grow_enabled             = true
  create_mode                   = "Default"
  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false
  public_network_access_enabled = false
  ssl_enforcement_enabled       = true
  # ssl_enforcement               = "Enabled"
  
  tags = {
    "Application or Service Name" = "vrd"
    "Environment"                 = "dev"
    "Operated By"                 = "skcc-cloudops"
    "Owner"                       = "skgc"
  }
}
