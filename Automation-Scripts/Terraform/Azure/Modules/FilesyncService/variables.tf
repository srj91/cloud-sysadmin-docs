variable "azure_region" {
  description = "The Azure region to deploy resources in"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "storage_account_id" {
  description = "The ID of the storage account"
  type        = string
}

variable "storage_account_name" {
  description = "The name of the storage account"
  type        = string
}

variable "file_share_name" {
  description = "The name of the file share"
  type        = string
}

variable "customer_name" {
  description = "The name of the customer"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
}
