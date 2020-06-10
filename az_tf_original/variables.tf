# Provider
variable "subscription_id" {
    type = string
}

variable "client_id" {
    type = string
}

variable "client_secret" {
    type = string
}

variable "tenant_id" {}

# Define Azure region for resource placement.
variable "location" {
    description = "Azure region for deployment of resources."
    type        = string
    default     = "uksouth"
}


variable "tags" {
    description = "A map of the tags to use for the resources that are deployed."
    type        = map
    default     = {
        tier        = "Infrastructure"
        environment = "Sandbox"
        owner       = "ang"
    }
}

# naming
variable "resource_suffix" {
    description = "Service suffix to use for naming of resources."
    type        = string
}

# cidr
variable "vnet_cidr" {}

variable "bastion_cidr" {}

variable "internal_cidr" {}

# vm
variable "pub_key" {}

variable "win_admin" {}