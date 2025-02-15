resource "azurerm_virtual_machine" "vm" {
  name                  = "vm-${random_integer.random_3digit.result}-${var.customer_name}"
  location              = var.azure_region
  resource_group_name   = var.resource_group_name
  #network_interface_ids = [azurerm_network_interface.nic.id]
  network_interface_ids = module.azurerm_network_interface.nic.id
  vm_size               = var.vm_size
#  admin_username        = var.admin_username
#  admin_password        = var.admin_password
#  computer_name         = "vm-${random_integer.random_3digit.result}-${var.customer_name}"
#  image_id              = var.image_id
  tags                  = var.tags

# Use latest windows Server 2019 DataCenter
  storage_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    #version   = var.image_version
  }

storage_os_disk {
    name              = "OsDisk-${var.customer_name}-${random_integer.random_3digit.result}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }
  os_profile {
    computer_name  = "vm-${random_integer.random_3digit.result}-${var.customer_name}"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_windows_config {
    provision_vm_agent        = true
#    enable_automatic_updates  = false
  }
}

  # Optional: Add extensions or custom script
  # extension {
  #   name                 = "custom_script"
  #   publisher             = "Microsoft.Azure.Extensions"
  #   type                  = "CustomScript"
  #   type_handler_version  = "1.10"
  #   settings              = jsonencode({
  #     script = "install.sh"
  #   }
  # }

resource "random_integer" "random_3digit" {
  min = 100
  max = 999
}
