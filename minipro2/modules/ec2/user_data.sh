#!/bin/bash

dnf install -q -y httpd php

cat <<EOF > /var/www/html/index.php
<h1>My Web Server</h1>
<p>DB Endpoint : ${db_endpoint}</p>
<p>DB Port     : ${db_port}</p>
EOF

systemctl enable --now httpd
