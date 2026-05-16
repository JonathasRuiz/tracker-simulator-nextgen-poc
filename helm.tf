# 1. Install Gateway API CRDs & Envoy Gateway Controller
resource "helm_release" "envoy_gateway" {
  name             = "envoy-gateway"
  repository       = "oci://docker.io/envoyproxy"
  chart            = "gateway-helm"
  version          = "v1.2.0"
  namespace        = "envoy-gateway-system"
  create_namespace = true

  set {
    name  = "installGatewayAPI"
    value = "true"
  }

  depends_on = [digitalocean_kubernetes_cluster.app_cluster]
}

# 2. Install the Next Gen Applications chart
resource "helm_release" "tracker_simulator_nextgen" {
  name             = "tracker-simulator-nextgen"
  chart            = "https://github.com/JonathasRuiz/tracker-simulator-next-gen/raw/refs/heads/master/tracker-simulator-nextgen-0.1.0.tgz"
  namespace        = "default"
  create_namespace = true

  values = [
    templatefile("${path.module}/tracker-simulator-nextgen.values.yaml", {
      droplet_ip       = digitalocean_droplet.compose_server.ipv4_address
      load_balancer_ip = var.load_balancer_ip
      google_api_key   = var.google_api_key
    })
  ]

  depends_on = [digitalocean_kubernetes_cluster.app_cluster]
}

# 3. Deploy Envoy Ingress service
resource "helm_release" "tracker_simulator_envoy_nextgen" {
  name             = "tracker-simulator-envoy-nextgen"
  chart            = "https://github.com/JonathasRuiz/tracker-simulator-envoy-nextgen/raw/refs/heads/master/tracker-simulator-envoy-nextgen-0.1.0.tgz"
  namespace        = "envoy-gateway-system"
  create_namespace = true

  values = [
    templatefile("${path.module}/tracker-simulator-envoy-nextgen.yaml", {})
  ]

  depends_on = [
    digitalocean_kubernetes_cluster.app_cluster,
    helm_release.envoy_gateway,
    helm_release.tracker_simulator_nextgen
  ]
}
