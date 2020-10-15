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
  resource_group_name     = var.k8s_resourcegroup
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
  tags = {
    "Application or Service Name" = "vrd"
    "Environment" = "prod"
    "Operated By" = "skcc-cloudops"
    "Owner" = "skgc"
  }
}
