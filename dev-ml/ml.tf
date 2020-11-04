

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


# resource "azurerm_storage_account" "file" {
#   name                     = "${module.const.short-name}file01"
#   resource_group_name      = azurerm_resource_group.rg.name
#   location                 = azurerm_resource_group.rg.location
#   account_tier             = "Standard"
#   account_kind             = "BlobStorage"
#   account_replication_type = "GRS"
#   tags                     = module.const.tags
# }
# resource "azurerm_storage_account" "dataset" {
#   name                     = "${module.const.short-name}mldefault"
#   resource_group_name      = azurerm_resource_group.rg.name
#   location                 = azurerm_resource_group.rg.location
#   account_tier             = "Standard"
#   account_kind             = "BlobStorage"
#   account_replication_type = "GRS"
#   tags                     = module.const.tags
# }
# resource "azurerm_storage_account" "vrd-dataset" {
#   name                     = "${module.const.short-name}dataset02"
#   resource_group_name      = azurerm_resource_group.rg.name
#   location                 = azurerm_resource_group.rg.location
#   account_tier             = "Standard"
#   account_kind             = "BlobStorage"
#   account_replication_type = "GRS"
#   tags                     = module.const.tags
# }


# resource "azurerm_key_vault" "keyvault" {
#   name                = "${module.const.short-name}mlkeyvault"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   tenant_id           = module.const.tenant
#   sku_name            = "premium"

#   tags = module.const.tags
# }

# resource "azurerm_application_insights" "loginsight" {
#   name                = "${module.const.long-name}-ml-loginsight"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   application_type    = "web"

#   tags = module.const.tags
# }

# resource "azurerm_machine_learning_workspace" "ml" {
#   name                    = "${module.const.long-name}-ml"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   application_insights_id = azurerm_application_insights.loginsight.id
#   key_vault_id            = azurerm_key_vault.keyvault.id
#   storage_account_id      = azurerm_storage_account.dataset.id

#   identity {
#     type = "SystemAssigned"
#   }
#   tags = module.const.tags
# }