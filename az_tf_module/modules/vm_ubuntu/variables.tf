variable "resource_prefix" {
    description = "Service prefix to use for naming of resources."
    type        = string
}

variable "rg_name" {
  description = "Resource group name"
  type        = string
}

variable "rg_location" {
  description = "Azure region for deployment of resources."
  type        = string
}

variable "snet_internal_id" {}

variable "pub_key" {}