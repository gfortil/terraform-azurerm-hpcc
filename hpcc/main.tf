resource "random_integer" "random" {
  min = 1
  max = 2
}

module "subscription" {
  source          = "github.com/Azure-Terraform/terraform-azurerm-subscription-data.git?ref=v1.0.0"
  subscription_id = data.azurerm_subscription.current.subscription_id
}

module "naming" {
  source = "github.com/Azure-Terraform/example-naming-template.git?ref=v1.0.0"
}

module "metadata" {
  source = "github.com/Azure-Terraform/terraform-azurerm-metadata.git?ref=v1.5.1"

  naming_rules = module.naming.yaml

  market              = var.metadata.market
  location            = local.location
  sre_team            = var.metadata.sre_team
  environment         = var.metadata.environment
  product_name        = var.metadata.product_name
  business_unit       = var.metadata.business_unit
  product_group       = var.metadata.product_group
  subscription_type   = var.metadata.subscription_type
  resource_group_type = var.metadata.resource_group_type
  subscription_id     = module.subscription.output.subscription_id
  project             = var.metadata.project
}

resource "null_resource" "launch_svc_urls" {
  for_each = module.hpcc.hpcc_status == "deployed" ? local.svc_domains : {}

  provisioner "local-exec" {
    command     = local.is_windows_os ? "Start-Process ${each.value}" : "open ${each.value} || xdg-open ${each.value}"
    interpreter = local.is_windows_os ? ["PowerShell", "-Command"] : ["/bin/bash", "-c"]
  }
}

resource "azurerm_role_assignment" "storage_account_contributor_over_sa" {
  scope                = "/subscriptions/${var.azure_auth.SUBSCRIPTION_ID}/resourceGroups/${local.external_storage_accounts[0].resource_group}/providers/Microsoft.Storage/storageAccounts/${local.external_storage_accounts[0].storage_account}"
  role_definition_name = "Storage Account Contributor"
  principal_id         = local.get_aks_config.cluster_identity.principal_id
}

resource "azurerm_role_assignment" "storage_account_contributor_over_subnet" {
  scope                = "/subscriptions/${var.azure_auth.SUBSCRIPTION_ID}/resourceGroups/${local.virtual_network_resource_group_name}/providers/Microsoft.Network/virtualNetworks/${local.virtual_network_name}/subnets/${local.subnet_name}"
  role_definition_name = "Storage Account Contributor"
  principal_id         = local.get_aks_config.cluster_identity.principal_id
}
