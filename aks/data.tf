data "azurerm_advisor_recommendations" "advisor" {

  filter_by_category        = ["Security", "Cost"]
  filter_by_resource_groups = [module.resource_groups["azure_kubernetes_service"].name]
}

data "http" "host_ip" {
  url = "https://api.ipify.org"
}

data "azurerm_subscription" "current" {
}

# data "azuread_group" "subscription_owner" {
#   object_id = var.azure_auth.AAD_OBJECT_ID
# }

data "azurerm_client_config" "current" {
}

# data "azurerm_user_assigned_identity" "example" {
#   name                = "${local.cluster_name}-agentpool"
#   resource_group_name = "mc_${local.cluster_name}"

#   depends_on = [module.aks]
# }
