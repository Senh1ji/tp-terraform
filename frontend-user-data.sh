#!/bin/bash

# Mise à jour du système
yum update -y

# Installation Node.js 16
curl -sL https://rpm.nodesource.com/setup_16.x | bash -
yum install -y nodejs git

# Installation nginx
amazon-linux-extras enable nginx1
yum install -y nginx

# Clone du repo Angular
git clone https://gitlab.com/imad-omar-nabi-projects/employee-frontend.git \
    /home/ec2-user/employee-frontend

cd /home/ec2-user/employee-frontend

# Correction URL backend
sed -i 's|http://localhost:8081/api/v1/employees|/api/v1/employees|g' \
    src/app/employee.service.ts

# Build Angular
npm install
npm run build -- --configuration=production

# Copie vers nginx
rm -rf /usr/share/nginx/html/*
cp -r /home/ec2-user/employee-frontend/dist/angular-frontend/* \
    /usr/share/nginx/html/

# Réécriture complète de nginx.conf
tee /etc/nginx/nginx.conf > /dev/null << 'NGINXCONF'
worker_processes  1;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;

    server {
        listen 80;
        server_name _;
        root /usr/share/nginx/html;
        index index.html;

        location / {
            try_files $uri $uri/ /index.html;
        }

        location /api/ {
            proxy_pass http://50.20.6.77:8081/api/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
}
NGINXCONF

# Démarrage nginx
nginx -t
systemctl enable nginx
systemctl start nginx
