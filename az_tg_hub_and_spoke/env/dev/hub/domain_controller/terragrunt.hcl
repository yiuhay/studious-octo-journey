terraform {
  source = "../../../../modules//vm_windows"
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
  rg_prefix            = local.global.rg_prefix
  vnet_prefix          = "hub-${local.global.env}"
  snet_name            = "server"

  vm_prefix            = "az-ad"
  instance_count       = "1"
  win_admin_password   = "WIN-ADMIN-PASSWORD"
  vm_size              = "Standard_B2s"
  
  additional_data_disk = false
  data_disk_type       = ""
  data_disk_size       = ""

  env                  = local.global.env
  project              = local.global.project
  owner                = local.global.owner
}
