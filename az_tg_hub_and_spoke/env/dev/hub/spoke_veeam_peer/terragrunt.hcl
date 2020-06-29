terraform {
  source = "../../../../modules//vnet_peering"
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
  paths = ["../network", "../../spoke_veeam/network"]
}

inputs = {
  rg_prefix         = local.global.rg_prefix

  hub_vnet_prefix   = "hub-${local.global.env}"
  spoke_vnet_prefix = "spoke-veeam-${local.global.env}"
}