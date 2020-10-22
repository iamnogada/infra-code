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
  source = "../const"
  env    = "prod"
}

##  user defined routetable
module "udr" {
  source   = "../modules/routetable"
  name     = module.const.long-name #"${var.owner}-${var.service}-${var.env}-${var.center}"
  location = module.const.location
  rg       = module.const.rg

  tags = module.const.tags
}

