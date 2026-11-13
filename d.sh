#!/bin/bash
# Liga cemaartes.com.br ao site da Cema (nginx + HTTPS Let's Encrypt).
# Não mexe nos outros sites do servidor. Pode rodar de novo sem problema.
D=cemaartes.com.br
IP=15.204.210.74
set -e
echo "== Atualizando o site"
if [ -d /var/www/cema-artes/.git ]; then git -C /var/www/cema-artes pull -q; else
  apt-get install -y git >/dev/null; git clone -q --depth 1 https://github.com/djowww/cema-artes.git /var/www/cema-artes; fi
echo "== Conferindo o DNS"
for h in $D www.$D; do
  r=$(getent ahostsv4 $h | awk '{print $1; exit}')
  if [ "$r" != "$IP" ]; then
    echo "ERRO: $h ainda aponta para '${r:-nada}', e não para $IP."
    echo "Confira o registro A na Hostinger e rode de novo daqui a uns minutos."; exit 1; fi
done
echo "DNS ok"
if [ ! -f /etc/nginx/conf.d/cema-dominio.conf ]; then
cat > /etc/nginx/conf.d/cema-dominio.conf <<CONF
server {
    listen 80;
    listen [::]:80;
    server_name $D www.$D;
    root /var/www/cema-artes;
    index index.html;
    location ~ /\.git { deny all; }
}
CONF
fi
nginx -t && systemctl reload nginx
echo "== Instalando o certificado HTTPS"
apt-get install -y certbot python3-certbot-nginx >/dev/null
certbot --nginx -d $D -d www.$D --non-interactive --agree-tos \
  --register-unsafely-without-email --redirect --keep-until-expiring
if ufw status 2>/dev/null | grep -q "Status: active"; then ufw allow 80/tcp; ufw allow 443/tcp; fi
echo "RESULTADO: $(curl -sI https://$D | head -1)"
