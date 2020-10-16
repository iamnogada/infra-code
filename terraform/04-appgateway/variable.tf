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

variable dmz_subnet_id {
    type = string
    default=""
}