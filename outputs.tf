output "advisor_recommendations" {
  value = data.azurerm_advisor_recommendations.advisor.recommendations
}
output "aks_login" {
  value = "az aks get-credentials --name ${azurerm_kubernetes_cluster.aks.name} --resource-group ${module.resource_group.name}"
}
