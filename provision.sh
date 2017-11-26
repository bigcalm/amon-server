#!/bin/bash

# Exit on 1st error
set -e

export FULL_HOSTNAME=`hostname -f`
export EMAIL_TO='sysops@example.com'

PROVISIONING_PATH=${PROVISIONING_PATH:-./}
PUBLIC_OR_PRIVATE=${PUBLIC_OR_PRIVATE:-${1:-public}}

cd ${PROVISIONING_PATH}

source mongodb.sh
source dependencies.sh
source amon.sh

if [[ ${PUBLIC_OR_PRIVATE} == 'public' ]]; then
    source letsencrypt.sh
else
    source selfsignedssl.sh
fi

source nginx.sh

# Ensure amon ownership of everything
chown -R amon:amon /opt/amon
chown -R amon:amon /etc/opt/amon
chown -R amon:amon /var/log/amon

