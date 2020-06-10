terraform {
  source = "../../../modules//network"
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
  paths = ["../rg"]
}

inputs = {
  resource_prefix = local.global.resource_prefix
  vnet_cidr       = local.global.vnet_cidr
  rg_name         = "${local.global.resource_prefix}-rg"
  rg_location     = local.global.location

  bastion_cidr    = local.global.bastion_cidr
  internal_cidr   = local.global.internal_cidr
}
