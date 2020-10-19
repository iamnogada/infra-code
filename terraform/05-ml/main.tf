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

resource "azurerm_application_insights" "skgc-vrd-dev-ml-loginsight" {
  name                = "skgc-vrd-dev-ml-loginsight"
  location            = var.location
  resource_group_name = var.resourcegroup
  application_type    = "web"

  tags = {
    "Application or Service Name" = "vrd"
    "Environment"                 = "dev"
    "Operated By"                 = "skcc-cloudops"
    "Owner"                       = "skgc"
  }
}

resource "azurerm_key_vault" "skgc-vrd-dev-keyvault" {
  name                = "skgc-vrd-dev-keyvault"
  location            = var.location
  resource_group_name = var.resourcegroup
  tenant_id           = var.tenant_id
  sku_name = "premium"

  tags = {
    "Application or Service Name" = "vrd"
    "Environment"                 = "dev"
    "Operated By"                 = "skcc-cloudops"
    "Owner"                       = "skgc"
  }
}

resource "azurerm_storage_account" "skgcvrddevmlstorage" {
  name                     = "skgcvrddevmlstorage"
  location                 = var.location
  resource_group_name      = var.resourcegroup
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    "Application or Service Name" = "vrd"
    "Environment"                 = "dev"
    "Operated By"                 = "skcc-cloudops"
    "Owner"                       = "skgc"
  }
}

resource "azurerm_machine_learning_workspace" "skgc-vrd-dev-ml" {
  name                    = "skgc-vrd-dev-ml"
  location                = var.location
  resource_group_name     = var.resourcegroup
  application_insights_id = azurerm_application_insights.skgc-vrd-dev-ml-loginsight.id
  key_vault_id            = azurerm_key_vault.skgc-vrd-dev-keyvault.id
  storage_account_id      = azurerm_storage_account.skgcvrddevmlstorage.id

  identity {
    type = "SystemAssigned"
  }
  tags = {
    "Application or Service Name" = "vrd"
    "Environment"                 = "dev"
    "Operated By"                 = "skcc-cloudops"
    "Owner"                       = "skgc"
  }
}