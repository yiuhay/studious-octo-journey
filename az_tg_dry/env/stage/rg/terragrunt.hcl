terraform {
  source = "../../../modules//rg"
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
    location        = local.global.location
    resource_prefix = local.global.resource_prefix
}