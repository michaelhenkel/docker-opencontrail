#!/bin/bash
echo "creating ks db" >> /tmp/stat
mysql -u root -p$ADMIN_PASSWORD -e "CREATE DATABASE keystone;"
mysql -u root -p$ADMIN_PASSWORD -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' \
  IDENTIFIED BY '$ADMIN_PASSWORD';"
mysql -u root -p$ADMIN_PASSWORD -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' \
  IDENTIFIED BY '$ADMIN_PASSWORD';"
echo "created ks db" >> /tmp/stat
