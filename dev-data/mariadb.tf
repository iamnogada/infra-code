
########  resource group for storage account
resource "azurerm_resource_group" "rg" {
  name     = "${module.const.long-name}-data-rg"
  location = module.const.location
  tags     = module.const.tags
}

######## subnet
module "data" {
  source = "../modules/subnet"
  name   = "${module.const.long-name}-data" #"skgc-vrd-prod-devops-koce"
  rg     = module.const.rg
  vnet   = module.const.vnet
  cidr   = ["10.242.19.128/26"]

}

resource "azurerm_mariadb_server" "data" {
  name                = "${module.const.short-name}dev01"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location

  administrator_login          = "vrdadmin"
  administrator_login_password = "Tnwpql12#$"

  sku_name   = "GP_Gen5_2"
  storage_mb = 5120
  version    = "10.2"

  auto_grow_enabled             = true
  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false
  public_network_access_enabled = true
  ssl_enforcement_enabled       = true

  tags     = module.const.tags
}