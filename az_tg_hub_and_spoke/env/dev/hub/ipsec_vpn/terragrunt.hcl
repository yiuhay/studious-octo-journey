terraform {
  source = "../../../../modules//ipsec_vpn"
}

include {
  path = find_in_parent_folders()
}

locals {
  default_yaml_path = find_in_parent_folders("env.yaml")

  global = yamldecode(
    file(find_in_parent_folders("env.yaml", local.default_yaml_path))
  )
}

dependencies {
  paths = ["../vnet"]
}

inputs = {
  rg_prefix        = local.global.rg_prefix
  vnet_prefix      = "hub-${local.global.env}"

  cidr_vgw         = "10.69.0.0/24"
  onprem_public    = "ONPREM-IP"
  onprem_private   = ["192.168.7.0/24", "192.168.11.0/24"]

  vpn_psk          = "VPN-PSK"

  dh_group         = "DHGroup24"
  ike_encryption   = "AES256"
  ike_integrity    = "SHA384"

  ipsec_encryption = "AES256"
  ipsec_integrity  = "SHA256"
  pfs_group        = "None"

  env              = local.global.env
  project          = local.global.project
  owner            = local.global.owner
}
