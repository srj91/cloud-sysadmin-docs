################# Comman Variables Definition ##################
variable "customer_name" {
  description = "The name of the customer."
  type        = string
}

variable "azure_region" {
  description = "The Azure region where resources will be created."
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to resources."
  type        = map(string)
}

############### Network Related Variables ################
# variable "resource_group_name" {
#   description = "The name of the resource group where resources will be placed."
#   type        = string
# }

variable "vnet_address_space" {
  description = "The address space for the virtual network."
  type        = list(string)
}

variable "subnet_address_prefixes" {
  description = "The address prefixes for the subnet."
  type        = list(string)
}

# variable "file_share_name" {
#   description = "The name of the file share."
#   type        = string
# }

variable "allow_dc" {
  description = "The IP address to allow for Domain Controllers"
  type        = string
}

variable "blocked_malicious_ips" {
  description = "The IP addresses to block as malicious"
  type        = string
}

variable "allow_adself_server" {
  description = "The IP address to allow for ADself Server"
  type        = string
}

variable "allow_nessus_azure_ip" {
  description = "The IP address to allow for Nessus Azure"
  type        = string
}

variable "allow_avd_ip" {
  description = "The IP range allowed access."
  type        = string
}

################# VM and Disk Related variables ################### 
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

variable "image_publisher" {
  description = "The publisher of the image used to create the virtual machine."
  type        = string
}

variable "image_offer" {
  description = "The offer of the image used to create the virtual machine."
  type        = string
}

variable "image_sku" {
  description = "The SKU of the image used to create the virtual machine."
  type        = string
}

variable "image_version" {
  description = "The version of the image used to create the virtual machine."
  type        = string
}

# variable "computer_name" {
#   description = "The name of the virtual machine."
# }

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

variable "image_id" {
  description = "The ID of the image to use for the VM."
  type        = string
}

