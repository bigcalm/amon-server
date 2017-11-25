#!/bin/bash

mkdir /etc/nginx/ssl

openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048

openssl genrsa -des3 -passout pass:x -out /tmp/server.pass.key 2048
openssl rsa -passin pass:x -in /tmp/server.pass.key -out /etc/nginx/ssl/server.key
rm /tmp/server.pass.key
openssl req -new -key /etc/nginx/ssl/server.key -out server.csr \
  -subj "/C=XX/ST=Foo/L=Bar/O=Baz/OU=Wibble/CN=${FULL_HOSTNAME}"
openssl x509 -req -days 365 -in server.csr -signkey /etc/nginx/ssl/server.key -out /etc/nginx/ssl/server.crt
rm server.csr

export SSL_PRIVATE_KEY="/etc/nginx/ssl/server.key"
export SSL_CERTIFICATE="/etc/nginx/ssl/server.crt"
export SSL_DHPARAM="/etc/nginx/ssl/dhparam.pem"
