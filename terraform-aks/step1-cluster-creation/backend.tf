terraform {
  backend "azurerm" {
    resource_group_name  = "sp_aks_group"
    storage_account_name = "springpetclinicstorageac"
    container_name       = "sp-storage-cont"
    key                  = "terraform.sp_storage_cont"
  }
}