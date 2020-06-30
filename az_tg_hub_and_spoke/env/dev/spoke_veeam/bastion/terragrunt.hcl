terraform {
  source = "../../../../modules//bastion"
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
  paths = ["../network"]
}

inputs = {
  rg_prefix    = local.global.rg_prefix
  location     = local.global.location

  vnet_prefix  = "spoke-veeam-${local.global.env}"

  snet_internal = "server"

  env          = local.global.env
  project      = local.global.project
  owner        = local.global.owner
}