variable "do_token" {
  description = "Digitalocean API token"
}

variable "ssh_key_file" {
  default     = "~/.ssh/id_rsa.pub"
  description = "Path to the SSH public key file"
}

variable "domain" {
  description = "Your public domain"
}

variable "subdomain" {
  description = "Your public subdomain"
  default     = "donate"
}

variable "letsencrypt_email" {
  description = "Email used to order a certificate from Letsencrypt"
}

variable "create_record" {
  default     = false
  description = "Whether to create a DNS record on Digitalocean"
}

variable "region" {
  default     = "ams3"
  description = "The Digitalocean region where the satsale droplet will be created."
}

variable "bitcoind_username" {
  default     = ""
  description = "The Username for the bitcoind instance that is set inside config.toml"
}

variable "bitcoind_password" {
  default     = ""
  description = "The Password for the bitcoind instance that is set inside config.toml"
}

variable "bitcoind_tunnel_host" {
  default     = ""
  description = "The SSH Tunnel Host (i.e; pi@IP) that is set inside config.toml"
}
