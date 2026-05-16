variable "ssh_public_key" {
  description = "SSH public key to install on the Droplet (contents of ~/.ssh/id_rsa.pub or similar)"
  type        = string
}

variable "do_token" {
  description = "DigitalOcean API Token"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "DigitalOcean Region"
  type        = string
  default     = "nyc3"
}

variable "load_balancer_ip" {
  description = "The dynamically generated Load Balancer IP"
  type        = string
  default     = "127.0.0.1" # The placeholder for the first pass
}

variable "google_api_key" {
  description = "A google api key provided to autocomplete addresses and fetch routes"
  type        = string
  default     = "YOUR_GOOGLE_API_KEY"
}

variable "node_count" {
  description = "Number of worker nodes in the K8s cluster"
  type        = number
  default     = 2
}
