output "managed_data_disk_id" {
  description = "The ID of the managed data disk."
  value       = azurerm_managed_disk.managed_data_disk.id
}

output "managed_disk_name" {
  description = "The name of the managed data disk."
  value       = azurerm_managed_disk.managed_data_disk.name
}

output "managed_disk_attachment_id" {
  description = "The ID of the managed data disk attachment."
  value       = azurerm_virtual_machine_data_disk_attachment.managed_data_disk_attachment.id
}

# output "virtual_machine_id" {
#   description = "The ID of the virtual machine."
#   value       = azurerm_virtual_machine.vm.id
# }
