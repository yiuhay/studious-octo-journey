# stage/terragrunt.hcl
remote_state {
  backend = "azurerm"
  config = {
    resource_group_name  = "YOUR_RESOURCE_GROUP_NAME"
    storage_account_name = "YOUR_STORAGE_ACCOUNT_NAME"
    container_name       = "YOUR_STORAGE_CONTAINER_NAME"
    key                  = "${path_relative_to_include()}/terraform.tfstate"

    # Access key stored as Environment Variable
  }
}