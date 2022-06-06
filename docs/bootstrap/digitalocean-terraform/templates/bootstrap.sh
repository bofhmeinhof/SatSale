#!/usr/bin/env bash

set -e -x -o pipefail

SUDO=sudo
export DOMAIN=${domain}
export LETSENCRYPT_EMAIL=${letsencrypt_email}
export BTCD_USERNAME=${bitcoind_username}
export BTCD_PASSWD=${bitcoind_password}
export BTCD_TUN_HOST=${bitcoind_tunnel_host}

setup() {

    git clone https://github.com/SatSale/SatSale.git && cd SatSale
    make setup
}

install_caddy() {

    $SUDO /sbin/sysctl -w net.ipv4.conf.all.forwarding=1
    echo "net.ipv4.conf.all.forwarding=1" | $SUDO tee -a /etc/sysctl.conf

    curl -sSL "https://github.com/caddyserver/caddy/releases/download/v2.4.3/caddy_2.4.3_linux_${suffix}.tar.gz" | $SUDO tar -xvz -C /usr/bin/ caddy
    $SUDO curl -fSLs https://raw.githubusercontent.com/caddyserver/dist/master/init/caddy.service --output /etc/systemd/system/caddy.service

    $SUDO mkdir -p /etc/caddy
    $SUDO mkdir -p /var/lib/caddy
    
    if $(id caddy >/dev/null 2>&1); then
      echo "User caddy already exists."
    else
      $SUDO useradd --system --home /var/lib/caddy --shell /bin/false caddy
    fi

    $SUDO tee /etc/caddy/Caddyfile >/dev/null <<EOF
{
  email "${LETSENCRYPT_EMAIL}"
}

${DOMAIN} {
  reverse_proxy 127.0.0.1:8080
}
EOF

    $SUDO chown --recursive caddy:caddy /var/lib/caddy
    $SUDO chown --recursive caddy:caddy /etc/caddy
    $SUDO systemctl daemon-reload
    $SUDO systemctl enable caddy
    $SUDO systemctl start caddy
  else
    echo "Skipping caddy installation."
  fi
}

template_bitcoind_config() {
  
  sed -i 's/bitcoinrpc/'$BTCD_USERNAME'/g' config.toml
  sed -i "12s/\"\"/'$BTCD_PASSWD'/g" config.toml
  sed -i '51s/^#//g' config.toml
  sed -i '51s/None/'$BTCD_TUN_HOST'/g' config.toml
}

setup
install_caddy