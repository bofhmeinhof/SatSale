locals {
  bitcoind_username = var.bitcoind_username
  bitcoind_password = var.bitcoind_password

  user_data_vars = {
    bitcoind_username   = local.bitcoind_username
    bitcoind_password   = local.bitcoind_password
    bitcoind_tunnel_host = local.bitcoind_tunnel_host
    domain              = var.domain
    email               = var.email
  }
}

resource "digitalocean_ssh_key" "satsale_ssh_key" {
  name       = "ssh-key"
  public_key = file(var.ssh_key_file)
}

resource "digitalocean_droplet" "satsale" {
  region    = var.region
  image     = "ubuntu-20-04-x64"
  name      = "satsale"
  size      = "s-1vcpu-1gb"
  ssh_keys = [
    digitalocean_ssh_key.satsale_ssh_key.id
  ]

  user_data = templatefile("${path.module}/templates/bootstrap.sh", local.user_data_vars)

}

resource "digitalocean_firewall" "satsale" {
  name = "Open ports 22, 80, 8000, and 8332"

  droplet_ids = [digitalocean_droplet.web.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "8000"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "8332"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }  
}

output "droplet_ip" {
  value = digitalocean_droplet.satsale.ipv4_address
}

output "gateway_url" {
  value = "https://${var.subdomain}.${var.domain}/"
}
