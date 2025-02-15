variable "azure_region" {
  description = "The Azure region to deploy resources in"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
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
