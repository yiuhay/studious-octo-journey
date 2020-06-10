output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "vnet_location" {
  value = azurerm_virtual_network.vnet.location
}

output "snet_bastion_id" {
  value = azurerm_subnet.snet_bastion.id
}

output "snet_internal_id" {
  value = azurerm_subnet.snet_internal.id
}

output "pip_bastion_id" {
  value = azurerm_public_ip.pip_bastion.id
}

output "nsg_bastion_name" {
  value = azurerm_network_security_group.nsg_bastion.name
}

output "nsg_bastion_id" {
  value = azurerm_network_security_group.nsg_bastion.id
}

output "nsg_internal_name" {
  value = azurerm_network_security_group.nsg_internal.name
}

output "nsg_internal_id" {
  value = azurerm_network_security_group.nsg_internal.id
}