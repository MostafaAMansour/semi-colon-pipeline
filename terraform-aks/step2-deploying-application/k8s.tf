resource "null_resource" "apply_k8s_files" {
  provisioner "local-exec" {
    command = "kubectl apply -R -f ../../kubernetes/"
  }
}