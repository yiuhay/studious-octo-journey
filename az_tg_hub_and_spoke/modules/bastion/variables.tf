variable "rg_prefix" {
    description = "Resource Group prefix."
    type        = string
}

variable "vnet_prefix" {
    description = "Virtual Network prefix."
    type        = string
}

variable "snet_internal" {
    description = "Internal subnet the bastion can connect to"
    type        = string
}

variable "env" {}

variable "project" {}

variable "owner" {}