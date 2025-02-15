# Configure the Azure Storage Account
resource "azurerm_storage_account" "stgacc" {
  name                     = "stgaccprdapp01${var.customer_name}"
  resource_group_name      = var.resource_group_name
  location                 = var.azure_region
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  tags                     = var.tags
}

resource "azurerm_storage_share" "fileshare" {
  name                 = "fileshare-${var.customer_name}"
  storage_account_name = azurerm_storage_account.stgacc.name
  quota                = 50
}
