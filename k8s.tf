resource "digitalocean_kubernetes_cluster" "app_cluster" {
  name    = "nextgen-k8s-cluster"
  region  = var.region
  version = "1.35.1-do.6"
  ha      = false

  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-4gb"
    node_count = var.node_count
  }
}

output "kubernetes_cluster_id" {
  value = digitalocean_kubernetes_cluster.app_cluster.id
}

output "kubeconfig" {
  value     = digitalocean_kubernetes_cluster.app_cluster.kube_config[0].raw_config
  sensitive = true
}
