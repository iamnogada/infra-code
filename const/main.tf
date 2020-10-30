
variable "owner"{
    default="skgc"
}
variable "service"{
    default="vrd"
}
variable "env"{
    # required
}
variable "center"{
    default="koce"
}
variable "operator"{
    default="skcc-cloudops"
}

data "azurerm_subscription" "current" {
}

output "tenant" {
  value = data.azurerm_subscription.current.tenant_id
}

output "location" { value = "koreacentral" }
output "vnet" { value = "vrd-001-vnet" }
output "udr" { value = "skgc-vrd-prod-koce-001-udr" }
output "rg" { value = "skgc-vrd-prod-koce-network-rg" }
output "ssl-keyvault" { value="/subscriptions/2dbedacf-40ac-4b61-8bdc-a3025e767aee/resourceGroups/skgc-vrd-prod-koce-network-rg/providers/Microsoft.KeyVault/vaults/skgcvrd-kubepia"}
# Mananged Identity
output "managed-identity"{ value ="/subscriptions/2dbedacf-40ac-4b61-8bdc-a3025e767aee/resourcegroups/skgc-vrd-prod-koce-network-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/skgc-vrd-ssl"}
output "long-name" {
  value = "${var.owner}-${var.service}-${var.env}-${var.center}"
}
output "short-name" {
  value = "${var.owner}${var.service}${var.env}"
}

output "owner" { value = var.owner}
output "service" { value = var.service}
output "env" { value = var.env}
output "center" { value = var.center}

output "tags" {
    value={
      "Application or Service Name" = var.service
      "Environment"                 = var.env
      "Operated By"                 = var.operator
      "Owner"                       = var.owner
    }
}
