#!/bin/bash
# Amazon Linux 2023 AMI - fedora
dnf install -q -y httpd mod_ssl
echo "<h1>My ALB WEB</h1>" > /var/www/html/index.html
systemctl enable --now httpd
