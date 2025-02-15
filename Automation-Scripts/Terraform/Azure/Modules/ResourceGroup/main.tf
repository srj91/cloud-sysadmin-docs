# Create the Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.azure_region}-prd-apprise-${var.customer_name}"
  location = var.azure_region
}

