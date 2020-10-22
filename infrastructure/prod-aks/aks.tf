
#  variable
variable aks {
  type = object({
    name    = string
    size    = string
    version = string
    count   = number
    cidr    = list(string)
  })
  default = {
    name    = "aks"
    size    = "Standard_D4_v3"
    version = "1.17.11"
    count   = 3
    cidr    = ["10.242.18.0/25"]
  }
}

# define in env exported : TF_VAR_client_id, TF_VAR_client_secret
variable client_id {}
variable client_secret {}
########################################################################
##  aks
########################################################################
resource "azurerm_resource_group" "aks-rg" {
  name     = "${local.owner}-${local.service}-${local.env}-${local.center}-aks-rg"
  location = var.location
  tags     = local.tags
}

module "aks-subnet" {
  source    = "../modules/subnet"
  name      = "${local.owner}-${local.service}-${local.env}-${local.center}-aks" #"skgc-vrd-prod-devops-koce"
  rg-name   = "skgc-vrd-prod-koce-network-rg"
  vnet-name = "vrd-001-vnet"
  cidr      = var.aks.cidr

}

data "azurerm_route_table" "udr" {
  name                = var.udr-name
  resource_group_name = var.nw-rg-name
}

# assign hub routing rule
resource "azurerm_subnet_route_table_association" "udr-association" {
  subnet_id      = module.aks-subnet.id
  route_table_id = data.azurerm_route_table.udr.id

  depends_on = [module.aks-subnet]
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${local.owner}-${local.service}-${local.env}-${local.center}-aks"
  resource_group_name = azurerm_resource_group.aks-rg.name
  location            = azurerm_resource_group.aks-rg.location

  kubernetes_version = var.aks.version
  dns_prefix         = "${local.owner}-${local.service}-${local.env}-aks"

  #TODO: Fixto private later
  private_cluster_enabled = false

  linux_profile {
    admin_username = "adminuser"

    ssh_key {
      key_data = file("../id_rsa.pub")
    }
  }
  default_node_pool {
    name           = "default"
    node_count     = 3
    vm_size        = var.aks.size
    vnet_subnet_id = module.aks-subnet.id
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }
  role_based_access_control {
    enabled = true
  }
  network_profile {
    docker_bridge_cidr = "172.17.0.1/16"
    dns_service_ip     = "10.2.0.10"
    network_plugin     = "kubenet"
    network_policy     = "calico"
    pod_cidr           = "172.110.0.0/16"
    service_cidr       = "10.2.0.0/24"
  }
  depends_on = [module.aks-subnet]
  tags       = local.tags
}
