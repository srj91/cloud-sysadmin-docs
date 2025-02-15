variable "resource_group_name" {
  description = "The name of the resource group."
}

variable "azure_region" {
  description = "The Azure region where resources will be created."
}

variable "customer_name" {
  description = "The name of the customer."
  type        = string
}

variable "vm_name" {
  description = "The name of the virtual machine."
  type        = string
}

variable "vm_id" {
  description = "The ID of the virtual machine."
  type        = string
}

variable "disk_size_gb" {
  description = "The size of the managed disk in GB."
  default     = 512
}

variable "storage_account_type" {
  description = "The storage account type for the managed disk."
  default     = "Premium_LRS"
}

variable "disk_lun" {
  description = "The Logical Unit Number (LUN) for the managed disk."
  default     = 0
}

variable "disk_caching" {
  description = "The caching type for the managed disk."
  default     = "ReadWrite"
}
