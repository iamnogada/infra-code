
########  resource group for storage account
resource "azurerm_resource_group" "rg" {
  name     = "${module.const.long-name}-ml-rg"
  location = module.const.location
  tags     = module.const.tags
}

######## subnet
module "ml" {
  source = "../modules/subnet"
  name   = "${module.const.long-name}-ml" #"skgc-vrd-prod-devops-koce"
  rg     = module.const.rg
  vnet   = module.const.vnet
  cidr   = ["10.242.19.192/26"]

}

resource "azurerm_storage_account" "file" {
  name                     = "${module.const.short-name}file01"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_kind             = "BlobStorage"
  account_replication_type = "GRS"
  
#   network_rules {
#     default_action             = "Deny"
#     ip_rules                   = ["100.0.0.1"]
#     virtual_network_subnet_ids = [module.ml.id]
#   }
  tags     = module.const.tags
}
resource "azurerm_storage_account" "dataset" {
  name                     = "${module.const.short-name}dataset01"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_kind             = "BlobStorage"
  account_replication_type = "GRS"
  
#   network_rules {
#     default_action             = "Deny"
#     ip_rules                   = ["100.0.0.1"]
#     virtual_network_subnet_ids = [module.ml.id]
#   }
  tags     = module.const.tags
}


# resource "azurerm_storage_account" "ml" {
#   name                     = "storageaccountname"
#   resource_group_name      = azurerm_resource_group.rg.name
#   location                 = azurerm_resource_group.rg.location
#   account_tier             = "Standard"
#   account_replication_type = "GRS"

#   tags = {
#     environment = "staging"
#   }
# }