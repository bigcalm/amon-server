#!/bin/bash

apt install -y python3-pip python3-dev python3-venv gcc libyaml-dev libev-dev git nginx

debconf-set-selections <<< "postfix postfix/mailname string ${FULL_HOSTNAME}"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
apt install -y postfix
