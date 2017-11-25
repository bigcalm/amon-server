#!/bin/bash

# Proxying with Nginx
tee /etc/nginx/sites-available/amon.conf << EOF
upstream app_server {
    server 127.0.0.1:8000 fail_timeout=15;
}

server {
    listen 80;
    server_name ${FULL_HOSTNAME};
    return 301 https://${FULL_HOSTNAME}\$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ipv6only=on;
    server_name  ${FULL_HOSTNAME};

    location / {
        proxy_read_timeout 30s;
        proxy_buffering    off;
        proxy_pass         http://app_server;
        proxy_redirect     off;
        proxy_set_header   Host \$http_host;
        proxy_set_header   X-Real-IP        \$remote_addr;
        proxy_set_header   X-Forwarded-For  \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Protocol ssl;
    }

    location /static {
        autoindex on;
        alias /opt/amon/amon/static;
    }

    ssl_certificate_key ${SSL_PRIVATE_KEY};
    ssl_certificate ${SSL_CERTIFICATE};
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';

    # Add perfect forward secrecy
    ssl_prefer_server_ciphers on;

    ssl_dhparam ${SSL_DHPARAM};

    # Add HSTS
    add_header Strict-Transport-Security "max-age=31536000; includeSubdomains";
}
EOF

cd /etc/nginx/sites-enabled
ln -sfn ../sites-available/amon.conf .

rm -f /etc/nginx/sites-enabled/default

systemctl restart nginx
