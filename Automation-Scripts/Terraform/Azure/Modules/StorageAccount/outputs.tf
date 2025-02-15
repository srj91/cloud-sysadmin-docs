output "storage_account_id" {
  value = azurerm_storage_account.stgacc.id
}

output "storage_account_name" {
  value = azurerm_storage_account.stgacc.name
}

output "file_share_name" {
  value = azurerm_storage_share.fileshare.name
}
