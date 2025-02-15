###################### Provider Registration ######################

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.46.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "random" {}

resource "random_integer" "random_3digit" {
  min = 100
  max = 999
}

###################### Resource Group Module ######################

module "resourcegroup" {
  source        = "./modules/resourcegroup"
  azure_region  = var.azure_region
  customer_name = var.customer_name
}

###################### Storage Account Module ######################
module "storageAccount" {
  source              = "./modules/storageAccount"
  azure_region        = var.azure_region
  resource_group_name = module.resourcegroup.resource_group_name
  customer_name       = var.customer_name
  tags                = var.tags
}

###################### File Sync Service Module ######################

module "filesyncservice" {
  source               = "./modules/FilesyncService"
  azure_region         = var.azure_region
  resource_group_name  = module.resourcegroup.resource_group_name
  storage_account_id   = module.storageAccount.storage_account_id
  storage_account_name = module.storageAccount.storage_account_name
  file_share_name      = module.storageAccount.file_share_name
  customer_name        = var.customer_name
  tags                 = var.tags
}

###################### Network Module ######################

module "network" {
  source                  = "./modules/Network"
  azure_region            = var.azure_region
  resource_group_name     = module.resourcegroup.resource_group_name
  customer_name           = var.customer_name
  tags                    = var.tags
  vnet_address_space      = var.vnet_address_space
  subnet_address_prefixes = var.subnet_address_prefixes
  allow_avd_ip            = var.allow_avd_ip
  allow_dc                = var.allow_dc
  blocked_malicious_ips   = var.blocked_malicious_ips
  allow_adself_server     = var.allow_adself_server
  allow_nessus_azure_ip   = var.allow_nessus_azure_ip
  #public_ip               = var.public_ip
}

###################### Virtual Machine Module ######################

module "virtualmachine" {
  source              = "./modules/VirtualMachine"
  azure_region        = var.azure_region
  resource_group_name = module.resourcegroup.resource_group_name
  customer_name       = var.customer_name
  tags                = var.tags
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  image_id            = var.image_id
  nic_id              = [var.nic_id]
  image_publisher     = var.image_publisher
  image_offer         = var.image_offer
  image_sku           = var.image_sku
  #version             = var.image_version
  #public_ip           = module.network.public_ip
}

###################### Managed Disk Module ######################

module "managedDisk" {
  source               = "./modules/ManagedDisk"
  azure_region         = var.azure_region
  customer_name        = var.customer_name
  resource_group_name  = module.resourcegroup.resource_group_name
  vm_name              = module.virtualmachine.vm_name
  vm_id                = module.virtualmachine.vm_id
  storage_account_type = var.storage_account_type
  disk_size_gb         = var.disk_size_gb
  disk_lun             = var.disk_lun
  disk_caching         = var.disk_caching
}

