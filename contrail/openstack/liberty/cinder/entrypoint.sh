#!/bin/bash
./openstack-config --set /etc/cinder/cinder.conf DEFAULT my_ip $HOST_IP
./openstack-config --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lock/cinder
if [ -n "$MYSQL_SERVER" ]; then
    ./openstack-config --set /etc/cinder/cinder.conf database connection mysql+pymysql://cinder:$ADMIN_PASSWORD@$MYSQL_SERVER/cinder
fi
if [ -n "$KEYSTONE_SERVER" ]; then
    ./openstack-config --del /etc/cinder/cinder.conf keystone_authtoken identity_uri
    ./openstack-config --del /etc/cinder/cinder.conf keystone_authtoken admin_tenant_name
    ./openstack-config --del /etc/cinder/cinder.conf keystone_authtoken admin_user
    ./openstack-config --del /etc/cinder/cinder.conf keystone_authtoken admin_password
    ./openstack-config --del /etc/cinder/cinder.conf keystone_authtoken revocation_cache_time
    ./openstack-config --set /etc/cinder/cinder.conf keystone_authtoken auth_uri http://$KEYSTONE_SERVER:5000
    ./openstack-config --set /etc/cinder/cinder.conf keystone_authtoken auth_url http://$KEYSTONE_SERVER:35357
    ./openstack-config --set /etc/cinder/cinder.conf keystone_authtoken auth_plugin password
    ./openstack-config --set /etc/cinder/cinder.conf keystone_authtoken project_domain_id default
    ./openstack-config --set /etc/cinder/cinder.conf keystone_authtoken user_domain_id default
    ./openstack-config --set /etc/cinder/cinder.conf keystone_authtoken project_name service
    ./openstack-config --set /etc/cinder/cinder.conf keystone_authtoken username cinder
    ./openstack-config --set /etc/cinder/cinder.conf keystone_authtoken password $ADMIN_PASSWORD
    ./openstack-config --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
fi
if [ -n "$RABBIT_SERVER" ]; then
    ./openstack-config --set /etc/cinder/cinder.conf DEFAULT rpc_backend rabbit
    ./openstack-config --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_host $RABBIT_SERVER
    ./openstack-config --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_userid guest
    ./openstack-config --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_password guest
fi

exec "$@"
