#!/bin/bash

if [ -n "$ADMIN_TOKEN" ]; then
    ./openstack-config --set /etc/keystone/keystone.conf DEFAULT admin_token $ADMIN_TOKEN
fi


if [ -n "$MYSQL_SERVER" ]; then
    ./openstack-config --set /etc/keystone/keystone.conf database connection mysql+pymysql://keystone:$ADMIN_PASSWORD@$MYSQL_SERVER/keystone
fi

if [ -n "$MEMCACHED_SERVER" ]; then
    ./openstack-config --set /etc/keystone/keystone.conf memcache servers $MEMCACHED_SERVER:11211
fi

if [ -n "$VERBOSE" ]; then
    ./openstack-config --set /etc/keystone/keystone.conf DEFAULT verbose True
fi

./openstack-config --set /etc/keystone/keystone.conf token provider uuid
./openstack-config --set /etc/keystone/keystone.conf token driver memcache
./openstack-config --set /etc/keystone/keystone.conf revoke driver sql

while ! nc -z $MYSQL_SERVER 3306; do
  sleep 0.1
done

mysql -h $MYSQL_SERVER -u root -p$ADMIN_PASSWORD -e "SHOW DATABASES;" |grep keystone
if [ $? -eq 1 ]; then
  mysql -h $MYSQL_SERVER -u root -p$ADMIN_PASSWORD -e "CREATE DATABASE keystone;"
  mysql -h $MYSQL_SERVER -u root -p$ADMIN_PASSWORD -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' \
        IDENTIFIED BY '$ADMIN_PASSWORD';"
  mysql -h $MYSQL_SERVER -u root -p$ADMIN_PASSWORD -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' \
        IDENTIFIED BY '$ADMIN_PASSWORD';"
fi

db_version=`keystone-manage db_version`
if [ $db_version -eq 43 ]; then
  keystone-manage db_sync
  /usr/bin/python /usr/bin/keystone-all &
  while ! nc -z localhost 35357; do
    sleep 0.1
  done
  openstack service create \
    --name keystone --description "OpenStack Identity" identity
  openstack endpoint create --region RegionOne \
    identity --publicurl http://$KEYSTONE_SERVER:5000/v2.0 \
    --adminurl http://$KEYSTONE_SERVER:35357/v2.0 \
    --internalurl http://$KEYSTONE_SERVER:5000/v2.0
  openstack project create --description "Admin Project" $ADMIN_USER
  openstack user create --password $ADMIN_PASSWORD  $ADMIN_USER
  openstack role create $ADMIN_USER
  openstack role add --project $ADMIN_USER --user $ADMIN_USER $ADMIN_USER
  openstack project create --description "Service Project" service
  kill -9 $(pidof python)
fi

exec "$@"
