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
module "const" {
  source   = "../const"
  env="dev"
}
