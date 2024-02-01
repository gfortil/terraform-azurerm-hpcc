provider "random" {
}

provider "azurerm" {
  features {}
  use_cli             = false
  storage_use_azuread = true

  tenant_id       = var.azure_auth.AAD_TENANT_ID
  client_id       = var.azure_auth.AAD_CLIENT_ID
  client_secret   = var.azure_auth.AAD_CLIENT_SECRET
  subscription_id = var.azure_auth.SUBSCRIPTION_ID
}

provider "azuread" {
  tenant_id     = var.azure_auth.AAD_TENANT_ID
  client_id     = var.azure_auth.AAD_CLIENT_ID
  client_secret = var.azure_auth.AAD_CLIENT_SECRET
}
