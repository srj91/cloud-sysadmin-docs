variable "azure_region" {
  description = "The Azure region where the VM will be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "customer_name" {
  description = "A customer-specific name for the VM."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the VM."
  type        = map(string)
}

variable "vm_size" {
  description = "The size of the virtual machine."
  type        = string
}

variable "admin_username" {
  description = "The admin username for the VM."
  type        = string
}

variable "admin_password" {
  description = "The admin password for the VM."
  type        = string
  sensitive   = true
}

variable "image_id" {
  description = "The ID of the image to use for the VM."
  type        = string
}

variable "nic_id" {
  description = "The ID of the Network Interface Card (NIC) to associate with the VM."
  type        = string
}

variable "image_publisher" {
  description = "The publisher of the image to use for the VM."
  type        = string
}

variable "image_offer" {
  description = "The offer of the image to use for the VM."
  type        = string
}

variable "image_sku" {
  description = "The SKU of the image to use for the VM."
  type        = string
}

variable "image_version" {
  description = "The version of the image to use for the VM."
  type        = string
  default     = "latest"
}
