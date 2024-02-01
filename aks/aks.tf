module "aks" {
  depends_on = [random_string.string]
  # source     = "github.com/gfortil/terraform-azurerm-aks.git?ref=HPCC-27615"
  source = "../../terraform-azurerm-aks"

  providers = {
    kubernetes = kubernetes.default
    helm       = helm.default
    kubectl    = kubectl.default
  }

  location            = var.metadata.location
  resource_group_name = module.resource_groups["azure_kubernetes_service"].name

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version
  # for v1.6.2 aks: network_plugin  = "kubenet"
  # for v1.6.2 aks: sku_tier_paid   = false
  sku_tier = var.sku_tier

  cluster_endpoint_access_cidrs = var.cluster_endpoint_access_cidrs

  virtual_network_resource_group_name = local.virtual_network_resource_group_name
  virtual_network_name                = local.virtual_network_name
  subnet_name                         = local.subnet_name
  route_table_name                    = local.route_table_name

  dns_resource_group_lookup = { "${var.internal_domain}" = var.dns_resource_group }

  admin_group_object_ids = [var.azure_auth.AAD_OBJECT_ID]

  rbac_bindings = {
    cluster_admin_users = merge(var.rbac_bindings.cluster_admin_users, {
      "service_principal" = data.azurerm_client_config.current.object_id
    })

    cluster_view_users  = merge(var.rbac_bindings.cluster_view_users, {})
    cluster_view_groups = concat(var.rbac_bindings.cluster_view_groups, [])
  }

  availability_zones = var.availability_zones

  system_nodes = var.system_nodes
  node_groups  = var.node_groups

  core_services_config = {
    alertmanager = var.core_services_config.alertmanager
    coredns      = var.core_services_config.coredns
    external_dns = var.core_services_config.external_dns
    cert_manager = var.core_services_config.cert_manager

    ingress_internal_core = {
      domain           = var.core_services_config.ingress_internal_core.domain
      subdomain_suffix = "${var.core_services_config.ingress_internal_core.subdomain_suffix}${trimspace(var.owner.name)}" // dns record suffix
      public_dns       = var.core_services_config.ingress_internal_core.public_dns
    }
  }

  tags = local.tags

  storage = {
    file = { enabled = true }
    blob = { enabled = true }
  }

  logging = var.logging

  experimental = {
    oms_agent                            = var.hpcc_log_analytics_enabled || var.experimental.oms_agent
    oms_agent_log_analytics_workspace_id = fileexists("../logging/data/workspace_resource_id.txt") ? file("../logging/data/workspace_resource_id.txt") : var.experimental.oms_agent_log_analytics_workspace_id != null ? var.experimental.oms_agent_log_analytics_workspace_id : null
  }
}
