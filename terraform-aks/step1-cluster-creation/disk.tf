resource "azurerm_managed_disk" "myAKSDisk" {
  name                 = "myAKSDisk"
  location             = local.location
  resource_group_name  = local.resource_group
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 4
  depends_on=[azurerm_resource_group.spring-petclinic]
  
}

resource "azurerm_role_assignment" "aks_disk_access" {
  principal_id   = azurerm_kubernetes_cluster.sp_aks.identity[0].principal_id
  role_definition_name = "Contributor"
  scope          = azurerm_managed_disk.myAKSDisk.id
  depends_on=[azurerm_managed_disk.myAKSDisk]
}