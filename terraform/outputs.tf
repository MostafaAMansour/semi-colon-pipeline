# output "kubernetes_host" {
#   value     = azurerm_kubernetes_cluster.semi-colon_aks.kube_config[0].host
#   sensitive = true
# }

# output "kubernetes_client_certificate" {
#   value     = azurerm_kubernetes_cluster.semi-colon_aks.kube_config[0].client_certificate
#   sensitive = true
# }

# output "kubernetes_client_key" {
#   value     = azurerm_kubernetes_cluster.semi-colon_aks.kube_config[0].client_key
#   sensitive = true
# }

# output "kubernetes_cluster_ca_certificate" {
#   value     = azurerm_kubernetes_cluster.semi-colon_aks.kube_config[0].cluster_ca_certificate
#   sensitive = true
# }

output "public_ip_address" {
  value = azurerm_public_ip.public_ip.ip_address
}