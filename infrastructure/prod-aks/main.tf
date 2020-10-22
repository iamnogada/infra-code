########################################################################
##  version and provider setting
########################################################################
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}
provider "azurerm" {
  features {}
}

locals {
  owner   = "skgc"
  service = "vrd"
  env     = "prod"
  center  = "koce"
  tags = {
    "Application or Service Name" = local.service
    "Environment"                 = local.env
    "Operated By"                 = "skcc-cloudops"
    "Owner"                       = local.owner
  }
}
variable location {
  type    = string
  default = "koreacentral"
}
variable nw-rg-name {
  type    = string
  default = "skgc-vrd-prod-koce-network-rg"
}
variable vnet-name {
  type    = string
  default = "vrd-001-vnet"
}
variable udr-name {
  type = string 
  default ="skgc-vrd-prod-koce-001-udr"
}

