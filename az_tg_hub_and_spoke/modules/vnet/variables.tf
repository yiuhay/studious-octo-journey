variable "rg_prefix" {
  description = "Resource group name prefix"
  type        = string
}

variable "location" {
  description = "Azure region for deployment of resources."
  type        = string
}

variable "vnet_prefix" {
    description = "Virtual Network prefix."
    type        = string
}

variable "cidr_vnet" {
  description = "The address space that is used by the virtual network."
}

variable "env" {}

variable "project" {}

variable "owner" {}