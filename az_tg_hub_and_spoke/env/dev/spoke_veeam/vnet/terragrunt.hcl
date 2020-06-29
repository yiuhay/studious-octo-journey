terraform {
  source = "../../../../modules//vnet"
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
  rg_prefix   = local.global.rg_prefix
  location    = local.global.location

  vnet_prefix = "spoke-veeam-${local.global.env}"
  cidr_vnet   = "10.70.0.0/16"

  env         = local.global.env
  project     = local.global.project
  owner       = local.global.owner
}