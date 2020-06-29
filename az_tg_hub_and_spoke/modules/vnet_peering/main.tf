resource "azurerm_virtual_network_peering" "hub-spoke-peer" {
  name                         = "${var.hub_vnet_prefix}-to-${var.spoke_vnet_prefix}-peer"
  resource_group_name          = "${var.rg_prefix}-rg"
  virtual_network_name         = data.virtual_network_name.hub_vnet.name
  remote_virtual_network_id    = data.virtual_network_name.spoke_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}