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
  # backend "azurerm" {
  #   resource_group_name   = "skgc-vrd-prod-koce-tstate-rg"
  #   storage_account_name  = "skgcvrdtstate"
  #   container_name        = "tstate"
  #   key                   = "terraform.tfstate"
  # }
}
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  features {}
}

########################################################################
##  variables subnet
########################################################################
variable location {
  type    = string
  default = "koreacentral"
}

variable rg-name {
    type = string
    default = "skgc-vrd-prod-koce-network-rg"
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

########################################################################
##  user defined routetable
########################################################################

module "udr" {
  source   = "../modules/routetable"
  name     = "${local.owner}-${local.service}-${local.env}-${local.center}" #"skgc-vrd-prod-devops-koce"
  location = var.location
  rg-name  = var.rg-name

  tags = local.tags
}

