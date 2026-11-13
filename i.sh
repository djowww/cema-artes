#!/bin/bash
# Instala o site da Cema Artes no nginx, porta 8090, sem mexer em outros sites.
set -e
apt-get install -y git >/dev/null
rm -rf /var/www/cema-artes
git clone --depth 1 https://github.com/djowww/cema-artes.git /var/www/cema-artes
cat > /etc/nginx/conf.d/cema-artes.conf <<'CONF'
server {
    listen 8090;
    listen [::]:8090;
    server_name _;
    root /var/www/cema-artes;
    index index.html;
    location ~ /\.git { deny all; }
}
CONF
nginx -t
systemctl reload nginx
if ufw status 2>/dev/null | grep -q "Status: active"; then ufw allow 8090/tcp; fi
echo "RESULTADO: $(curl -sI http://localhost:8090 | head -1)"
