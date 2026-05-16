resource "digitalocean_ssh_key" "default" {
  name       = "nextgen-deploy-key"
  public_key = var.ssh_public_key
}

resource "digitalocean_droplet" "compose_server" {
  image      = "ubuntu-24-04-x64"
  name       = "nextgen-compose-node"
  region     = var.region
  size       = "s-2vcpu-4gb"
  ssh_keys   = [digitalocean_ssh_key.default.fingerprint]
  user_data  = file("${path.module}/cloud-init.yaml")
}

output "droplet_ip" {
  value = digitalocean_droplet.compose_server.ipv4_address
}
