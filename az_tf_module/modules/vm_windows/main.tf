terraform {
  required_version = ">= 0.12"
}

resource "azurerm_network_interface" "nic_windows" {
  name                = "${var.resource_prefix}-nic-windows"
  resource_group_name = var.rg_name
  location            = var.rg_location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.snet_internal_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "windows" {
  name                = "${var.resource_prefix}-vmwin"
  resource_group_name = var.rg_name
  location            = var.rg_location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = var.win_admin
  network_interface_ids = [
    azurerm_network_interface.nic_windows.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
