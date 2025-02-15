output "storage_sync_id" {
  description = "The ID of the storage sync service"
  value       = azurerm_storage_sync.filesync.id
}

output "storage_sync_name" {
  description = "The name of the storage sync service"
  value       = azurerm_storage_sync.filesync.name
}

output "storage_sync_group_id" {
  description = "The ID of the storage sync group"
  value       = azurerm_storage_sync_group.syncgroup.id
}

output "cloud_endpoint_id" {
  description = "The ID of the cloud endpoint"
  value       = azurerm_storage_sync_cloud_endpoint.cloudendpoint.id
}
