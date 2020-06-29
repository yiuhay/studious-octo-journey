data "azurerm_virtual_network" "hub_vnet" {
  name                = "${var.hub_vnet_prefix}-vnet"
  resource_group_name = "${var.rg_prefix}-rg"
}

data "azurerm_virtual_network" "spoke_vnet" {
  name                = "${var.spoke_vnet_prefix}-vnet"
  resource_group_name = "${var.rg_prefix}-rg"
}
