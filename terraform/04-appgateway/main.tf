# resource "azurerm_kubernetes_cluster" "skgc-vrd-prod-app-aks" {
#   name                = "skgc-vrd-prod-app-aks"
#   location            = var.location
#   resource_group_name = var.resourcegroup
#   dns_prefix          = "vrd-aks-app-dns"

#   default_node_pool {
#     name       = "default"
#     node_count = 3
#     vm_size    = "Standard_D2_v2"
#   }

#   # service_principal {
#   #   client_id     = "00000000-0000-0000-0000-000000000000"
#   #   client_secret = "00000000000000000000000000000000"
#   # }
# }

# resource "azurerm_kubernetes_cluster_node_pool" "example" {
#   name                  = "internal"
#   kubernetes_cluster_id = azurerm_kubernetes_cluster.example.id
#   vm_size               = "Standard_DS2_v2"
#   node_count            = 1

#   tags = {
#     Environment = "Production"
#   }
# }

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

resource "azurerm_kubernetes_cluster" "vrd-aks" {
  name                    = "vrd-prod-aks"
  location                = var.location
  kubernetes_version      = "1.17.11"
  resource_group_name     = var.resourcegroup
  dns_prefix              = "vrd-aks"
  private_cluster_enabled = true

  default_node_pool {
    name           = "default"
    node_count     = 3
    vm_size        = var.nodepool_vm_size
    vnet_subnet_id = var.k8s_subnet_id
  }

  # identity {
  #   type = "SystemAssigned"
  # }
  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  network_profile {
    docker_bridge_cidr = "172.17.0.1/16"
    dns_service_ip     = "10.2.0.10"
    network_plugin     = "kubenet"
    network_policy     = "calico"
    pod_cidr           = "172.110.0.0/16"
    service_cidr       = "10.2.0.0/24"
  }
}
