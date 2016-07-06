#!/bin/bash
echo "creating glance db" >> /tmp/stat
mysql -u root -p$ADMIN_PASSWORD -e "CREATE DATABASE glance;"
mysql -u root -p$ADMIN_PASSWORD -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' \
  IDENTIFIED BY '$ADMIN_PASSWORD'"
mysql -u root -p$ADMIN_PASSWORD -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' \
  IDENTIFIED BY '$ADMIN_PASSWORD';"
echo "created glance db" >> /tmp/stat
