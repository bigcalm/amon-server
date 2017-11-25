#!/bin/bash

# Create the directories where you are going to store the configs, logs and Amon itself
mkdir -p /opt/amon
mkdir -p /var/log/amon
mkdir -p /etc/opt/amon

# Create the amon user
useradd --system --user-group --key USERGROUPS_ENAB=yes -M amon --shell /bin/false -d /etc/opt/amon

chown -R amon:amon /opt/amon
chown -R amon:amon /etc/opt/amon
chown -R amon:amon /var/log/amon

git clone https://github.com/amonapp/amon.git /opt/amon

tee /etc/opt/amon/amon.yml << EOF
host: https://${FULL_HOSTNAME}
smtp:
  host: 127.0.0.1
  port: 25
  use_tls: false
  sent_from: alerts@${FULL_HOSTNAME}
EOF

bash -c "
# Setting up an Environment
python3 -m venv /opt/amon/env/

# Activate the environment
source /opt/amon/env/bin/activate
pip install wheel
pip install -r /opt/amon/requirements.txt

# Create the database and check if Amon is running
cd /opt/amon
python manage.py migrate

python manage.py installtasks  # Alert sending / Cloud Sync / Agent no data sent cron tasks

# To test if Amon is configured properly
# python manage.py runserver
"

# Running Amon as a Service
tee /etc/systemd/system/amon.service << EOF
[Unit]
Description=Amon
After=network.target

[Service]
Type=simple
User=amon
Group=amon
WorkingDirectory=/opt/amon/
ExecStart=/opt/amon/env/bin/gunicorn wsgi -c /opt/amon/gunicorn.conf

[Install]
WantedBy=multi-user.target
EOF

systemctl enable amon
systemctl start amon
