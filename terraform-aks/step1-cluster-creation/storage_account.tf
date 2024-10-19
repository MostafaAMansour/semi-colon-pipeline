resource "azurerm_storage_account" "springpetclinicstorageac" {
  name                     = "springpetclinicstorageac"  
  resource_group_name      = local.resource_group
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create a storage container
resource "azurerm_storage_container" "sp-storage-cont" {
  name                  = "sp-storage-cont"
  storage_account_name  = azurerm_storage_account.springpetclinicstorageac.name
  container_access_type = "private"
}