#!/bin/bash
./openstack-config --set /etc/glance/glance-api.conf DEFAULT notification_driver noop
./openstack-config --set /etc/glance/glance-api.conf glance_store default_store file
./openstack-config --set /etc/glance/glance-api.conf glance_store filesystem_store_datadir = /var/lib/glance/images/
if [ -n "$MYSQL_SERVER" ]; then
    ./openstack-config --del /etc/glance/glance-api.conf database sqlite_db
    ./openstack-config --set /etc/glance/glance-api.conf database connection mysql+pymysql://glance:$ADMIN_PASSWORD@$MYSQL_SERVER/glance
fi
if [ -n "$KEYSTONE_SERVER" ]; then
    ./openstack-config --del /etc/glance/glance-api.conf keystone_authtoken identity_uri
    ./openstack-config --del /etc/glance/glance-api.conf keystone_authtoken admin_tenant_name
    ./openstack-config --del /etc/glance/glance-api.conf keystone_authtoken admin_user
    ./openstack-config --del /etc/glance/glance-api.conf keystone_authtoken admin_password
    ./openstack-config --del /etc/glance/glance-api.conf keystone_authtoken revocation_cache_time
    ./openstack-config --set /etc/glance/glance-api.conf keystone_authtoken auth_uri http://$KEYSTONE_SERVER:5000
    ./openstack-config --set /etc/glance/glance-api.conf keystone_authtoken auth_url http://$KEYSTONE_SERVER:35357
    ./openstack-config --set /etc/glance/glance-api.conf keystone_authtoken auth_plugin password
    ./openstack-config --set /etc/glance/glance-api.conf keystone_authtoken project_domain_id default
    ./openstack-config --set /etc/glance/glance-api.conf keystone_authtoken user_domain_id default
    ./openstack-config --set /etc/glance/glance-api.conf keystone_authtoken project_name service
    ./openstack-config --set /etc/glance/glance-api.conf keystone_authtoken username glance
    ./openstack-config --set /etc/glance/glance-api.conf keystone_authtoken password $ADMIN_PASSWORD
    ./openstack-config --set /etc/glance/glance-api.conf paste_deploy flavor keystone
fi
if [ -n "$VERBOSE" ]; then
    ./openstack-config --set /etc/glance/glance-api.conf DEFAULT verbose True
fi

mysql -h $MYSQL_SERVER -u root -p$ADMIN_PASSWORD -e "SHOW DATABASES;" |grep glance
if [ $? -eq 1 ]; then
  while ! nc -z $MYSQL_SERVER 3306; do
    sleep 0.1
  done
  mysql -h $MYSQL_SERVER -u root -p$ADMIN_PASSWORD -e "CREATE DATABASE glance;"
  mysql -h $MYSQL_SERVER -u root -p$ADMIN_PASSWORD -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' \
        IDENTIFIED BY '$ADMIN_PASSWORD';"
  mysql -h $MYSQL_SERVER -u root -p$ADMIN_PASSWORD -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' \
        IDENTIFIED BY '$ADMIN_PASSWORD';"
fi

db_version=`glance-manage db_version`
if [ $db_version -eq 0 ]; then
  glance-manage db_sync
fi
/usr/bin/python /usr/bin/glance-api &
while ! nc -z localhost 9292; do
  sleep 0.1
done
while ! nc -z $KEYSTONE_SERVER 35357; do
  sleep 0.1
done
openstack user show glance
if [ $? -eq 1 ]; then
  openstack user create --password $ADMIN_PASSWORD glance
  openstack role add --project service --user glance $ADMIN_USER
fi
openstack service show glance
if [ $? -eq 1 ]; then
  openstack service create --name glance --description "OpenStack Image service" image
fi
openstack endpoint show glance
if [ $? -eq 1 ]; then
  openstack endpoint create --region RegionOne image \
    --publicurl http://$GLANCE_API_SERVER:9292 \
    --adminurl http://$GLANCE_API_SERVER:9292 \
    --internalurl http://$GLANCE_API_SERVER:9292
fi
kill -9 $(pidof python)

exec "$@"
