# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  # Authenticate using a Service Principal
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id  = var.subscription_id
}