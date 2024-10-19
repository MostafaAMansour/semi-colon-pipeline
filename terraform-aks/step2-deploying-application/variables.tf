locals {
  resource_group="sp_aks_group"
  location="UK South"
}
variable "environment" {
  type    = string
  default = "dev"
}