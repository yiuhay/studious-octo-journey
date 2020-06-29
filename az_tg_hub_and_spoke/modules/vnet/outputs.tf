output "rg_prefix" {
  value = var.rg_prefix
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "vnet_location" {
  value = azurerm_virtual_network.vnet.location
}