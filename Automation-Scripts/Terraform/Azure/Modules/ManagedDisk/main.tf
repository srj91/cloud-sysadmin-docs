terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.46.0"
    }
  }
}

provider "azurerm" {
  features {}
}

#provider "random" {}

# Generate a random 3-digit number
resource "random_integer" "random_3digit" {
  min = 100
  max = 999
}

resource "azurerm_managed_disk" "managed_data_disk" {
  name                 = "DataDisk-${random_integer.random_3digit.result}-${var.customer_name}"
  location             = var.azure_region
  resource_group_name  = var.resource_group_name
  storage_account_type = var.storage_account_type
  create_option        = "Empty"
  disk_size_gb         = var.disk_size_gb
}

resource "azurerm_virtual_machine_data_disk_attachment" "managed_data_disk_attachment" {
  managed_disk_id    = azurerm_managed_disk.managed_data_disk.id
  virtual_machine_id = var.vm_id
  lun                = var.disk_lun
  caching            = var.disk_caching
}

