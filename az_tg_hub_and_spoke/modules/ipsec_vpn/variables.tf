variable "rg_prefix" {
    description = "Resource Group prefix."
    type        = string
}

variable "vnet_prefix" {
    description = "Virtual Network prefix."
    type        = string
}


variable "cidr_vgw" {
  description = "The address space that is used by the GatewaySubnet."  
}

variable "onprem_public" {
  description = "Key Vault stored public address of the on premise target"
}

variable "onprem_private" {
  description = "A list of address ranges the on premise target will expose"
  type        = list
  default     = []
}

variable "vpn_psk" {
  description = "Key Vault stored VPN PSK"
  type        = string
}

variable "dh_group" {
  description = "Phase 1"
  type        = string 
}

variable "ike_encryption" {
  description = "Phase 1"
  type        = string 
}

variable "ike_integrity" {
  description = "Phase 1"
  type        = string    
}

variable "ipsec_encryption" {
  description = "Phase 2"
  type        = string 
}

variable "ipsec_integrity" {
  description = "Phase 2"
  type        = string 
}

variable "pfs_group" {
  description = "Phase 2"
  type        = string    
}

variable "env" {}

variable "project" {}

variable "owner" {}