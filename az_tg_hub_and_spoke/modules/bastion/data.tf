data "azurerm_virtual_network" "vnet" {
  name                = "${var.vnet_prefix}-vnet"
  resource_group_name = "${var.rg_prefix}-rg"
}

data "azurerm_subnet" "snet_bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = "${var.rg_prefix}-rg"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
}