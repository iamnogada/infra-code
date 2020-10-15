variable subscription_id {
    type = string
    description=" tenant's subscription id"
}

variable location {
    type = string
    default ="koreacentral"
}

variable default_vnet {
    type = string
}

variable resourcegroup {
    type = string
    default="skgc-vrd-prod-koce-app-rg"
}
variable default_resourcegroup {
    type = string
}

variable nodepool_vm_size {
    type = string
    default= "Standard_D4_v3"
}

variable k8s_subnet_id {
    type=string
    default =""
}

variable default_route_id {
    type = string
}

variable client_id {
    type = string
}

variable client_secret {
    type = string
}