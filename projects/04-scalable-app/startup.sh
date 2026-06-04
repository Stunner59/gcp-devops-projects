#!/bin/bash

apt-get update
apt-get install -y nginx

HOSTNAME=$(hostname)

cat <<EOF > /var/www/html/index.html
<h1>Hello from $HOSTNAME</h1>
EOF

systemctl enable nginx
systemctl restart nginx
