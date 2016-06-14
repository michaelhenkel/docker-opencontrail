#!/bin/bash
./openstack-config --set /etc/glance/glance-registry.conf DEFAULT notification_driver noop
if [ -n "$MYSQL_SERVER" ]; then
    ./openstack-config --del /etc/glance/glance-registry,conf database sqlite_db
    ./openstack-config --set /etc/glance/glance-registry.conf database connection mysql://glance:$ADMIN_PASSWORD@$MYSQL_SERVER/glance
fi
if [ -n "$KEYSTONE_SERVER" ]; then
    ./openstack-config --del /etc/glance/glance-registry.conf keystone_authtoken identity_uri
    ./openstack-config --del /etc/glance/glance-registry.conf keystone_authtoken admin_tenant_name
    ./openstack-config --del /etc/glance/glance-registry.conf keystone_authtoken admin_user
    ./openstack-config --del /etc/glance/glance-registry.conf keystone_authtoken admin_password
    ./openstack-config --del /etc/glance/glance-registry.conf keystone_authtoken revocation_cache_time
    ./openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken auth_uri http://$KEYSTONE_SERVER:5000
    ./openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken auth_url http://$KEYSTONE_SERVER:35357
    ./openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken auth_plugin password
    ./openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken user_domain_id default
    ./openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken project_name service
    ./openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken project_domain_id default
    ./openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken username glance
    ./openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken password $ADMIN_PASSWORD
    ./openstack-config --set /etc/glance/glance-registry.conf paste_deploy flavor keystone
fi

exec "$@"
