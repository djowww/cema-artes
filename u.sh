#!/bin/bash
# Atualiza o site da Cema na VPS agora e deixa atualizando sozinho a cada 5 minutos.
set -e
git -C /var/www/cema-artes pull -q
echo '*/5 * * * * root git -C /var/www/cema-artes pull -q >/dev/null 2>&1' > /etc/cron.d/cema-artes
chmod 644 /etc/cron.d/cema-artes
echo "RESULTADO: site atualizado ($(git -C /var/www/cema-artes log -1 --format=%h)) e atualização automática ligada."
