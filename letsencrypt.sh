#!/bin/bash

mkdir -p /etc/ssl/certs/
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

git clone https://github.com/certbot/certbot /usr/local/letsencrypt

mkdir -p /etc/letsencrypt/

/usr/local/letsencrypt/certbot-auto --non-interactive --os-packages-only

/usr/local/letsencrypt/certbot-auto certonly --non-interactive --agree-tos --email ${EMAIL_TO} --standalone -d ${FULL_HOSTNAME}

(crontab -l ; echo "42 3 1,14 * * /usr/local/letsencrypt/certbot-auto certonly --non-interactive --standalone --pre-hook 'systemctl stop nginx' --post-hook 'systemctl start nginx' -d '${FULL_HOSTNAME}'")| crontab -

export SSL_PRIVATE_KEY="/etc/letsencrypt/live/${FULL_HOSTNAME}/privkey.pem"
export SSL_CERTIFICATE="/etc/letsencrypt/live/${FULL_HOSTNAME}/fullchain.pem"
export SSL_DHPARAM="/etc/ssl/certs/dhparam.pem"
