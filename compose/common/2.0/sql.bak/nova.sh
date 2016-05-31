#!/bin/bash
echo "creating nova db" >> /tmp/stat
mysql -u root -p$ADMIN_PASSWORD -e "CREATE DATABASE nova;"
mysql -u root -p$ADMIN_PASSWORD -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' \
  IDENTIFIED BY '$ADMIN_PASSWORD';"
mysql -u root -p$ADMIN_PASSWORD -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' \
  IDENTIFIED BY '$ADMIN_PASSWORD';"
echo "created nova db" >> /tmp/stat
