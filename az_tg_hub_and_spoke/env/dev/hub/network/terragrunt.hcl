terraform {
  source = "../../../../modules//network"
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

inputs = {
  rg_prefix     = local.global.rg_prefix
  location      = local.global.location

  vnet_prefix   = "hub-${local.global.env}"
  cidr_vnet     = "10.69.0.0/16"
  snet_prefixes = ["10.69.11.0/24", "10.69.7.0/24", "10.69.0.0/24"]
  snet_names    = ["server", "AzureBastionSubnet", "GatewaySubnet"]

  env           = local.global.env
  project       = local.global.project
  owner         = local.global.owner
}