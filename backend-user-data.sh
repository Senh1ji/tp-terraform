#!/bin/bash

# 1. Mise à jour du système
yum update -y

# 2. Installation Python3 + git
yum install -y python3 python3-pip git

# 3. Installation Node.js 18 (requis pour pm2)
curl -sL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# 4. Installation pm2
npm install -g pm2

# 5. Clone du repo GitLab
git clone https://gitlab.com/imad-omar-nabi-projects/employee-backend.git \
    /home/ec2-user/employee-backend

cd /home/ec2-user/employee-backend

# 6. Correction app.py pour écouter sur 0.0.0.0
sed -i "s/app.run(debug=True, port=8081)/app.run(debug=True, host='0.0.0.0', port=8081)/" \
    /home/ec2-user/employee-backend/app.py

# 7. Installation des dépendances Python
pip3 install -r requirements.txt

# 8. Permissions
chown -R ec2-user:ec2-user /home/ec2-user/employee-backend

# 9. Lancement Flask via pm2 en tant que ec2-user
sudo -u ec2-user pm2 start python3 --name "employee-backend" \
    --cwd /home/ec2-user/employee-backend -- app.py

# 10. Persistance au reboot
sudo -u ec2-user pm2 save
env PATH=$PATH:/usr/bin pm2 startup systemd -u ec2-user --hp /home/ec2-user