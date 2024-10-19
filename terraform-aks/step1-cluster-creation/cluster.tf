resource "azurerm_kubernetes_cluster" "sp_aks" {
  name                = "sp_aks"
  location            = local.location
  resource_group_name = local.resource_group
  dns_prefix          = "sp-aks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
    upgrade_settings {
      drain_timeout_in_minutes      = 0 
      max_surge                     = "10%" 
      node_soak_duration_in_minutes = 0
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
  depends_on=[azurerm_resource_group.spring-petclinic]
}

resource "azurerm_kubernetes_cluster_node_pool" "sp_aks_node" {
  name                  = "spaksnode"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.sp_aks.id
  vm_size               = "Standard_B2s"
  node_count            = 1
  max_pods              = 30
  mode                  = "User"
  auto_scaling_enabled   = false
  depends_on=[azurerm_kubernetes_cluster.sp_aks]
}

