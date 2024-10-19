terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "2.15.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.32.0"
    }
  }
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.step1.outputs.kubernetes_host
  client_certificate     = base64decode(data.terraform_remote_state.step1.outputs.kubernetes_client_certificate)
  client_key             = base64decode(data.terraform_remote_state.step1.outputs.kubernetes_client_key)
  cluster_ca_certificate = base64decode(data.terraform_remote_state.step1.outputs.kubernetes_cluster_ca_certificate)
}
