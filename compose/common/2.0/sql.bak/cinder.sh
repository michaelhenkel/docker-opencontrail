#!/bin/bash
echo "creating cinder db" >> /tmp/stat
mysql -u root -p$ADMIN_PASSWORD -vvv -e "CREATE DATABASE cinder;" >> /tmp/stat
mysql -u root -p$ADMIN_PASSWORD -vvv -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' \
  IDENTIFIED BY '$ADMIN_PASSWORD';" >> /tmp/stat
mysql -u root -p$ADMIN_PASSWORD -vvv -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' \
  IDENTIFIED BY '$ADMIN_PASSWORD';" >> /tmp/stat
echo "created cinder db" >> /tmp/stat
