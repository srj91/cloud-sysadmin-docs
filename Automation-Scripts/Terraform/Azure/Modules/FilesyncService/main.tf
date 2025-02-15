resource "azurerm_storage_sync" "filesync" {
  name                = "Filesync-${var.customer_name}"
  resource_group_name = var.resource_group_name
  location            = var.azure_region
  tags                = var.tags
}

resource "azurerm_storage_sync_group" "syncgroup" {
  name            = "Syncgroup-01-${var.customer_name}"
  storage_sync_id = azurerm_storage_sync.filesync.id
}

resource "azurerm_storage_sync_cloud_endpoint" "cloudendpoint" {
  name                  = "CloudEndpoint-${var.customer_name}"
  storage_sync_group_id = azurerm_storage_sync_group.syncgroup.id
  storage_account_id    = var.storage_account_id
  file_share_name       = var.file_share_name
}
