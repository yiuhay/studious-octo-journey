terraform {
  source = "../../../modules//network"
}

locals {
  default_yaml_path = find_in_parent_folders("env.yaml")

  global = yamldecode(
    file(find_in_parent_folders("env.yaml", local.default_yaml_path))
  )
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
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
