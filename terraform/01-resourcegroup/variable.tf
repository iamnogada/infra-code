variable subscription_id {
    type = string
    description=" tenant's subscription id"
}

variable default_vnet {
    type =string
    default=""
}
variable location {
    type = string
    default ="koreacentral"
}

variable resourcegroups {
    default = {}
}