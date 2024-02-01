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

# provider "kubernetes" {
#   host                   = local.get_aks_config.kube_admin_config[0].host
#   client_certificate     = base64decode(local.get_aks_config.kube_admin_config[0].client_certificate)
#   client_key             = base64decode(local.get_aks_config.kube_admin_config[0].client_key)
#   cluster_ca_certificate = base64decode(local.get_aks_config.kube_admin_config[0].cluster_ca_certificate)
# }
