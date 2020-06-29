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

output "snet_id" {
  description = "The ids of subnets created"
  value       = azurerm_subnet.subnet.*.id
}