#!/bin/bash

if [ -n "$ADMIN_TOKEN" ]; then
    ./openstack-config --set /etc/keystone/keystone.conf DEFAULT admin_token $ADMIN_TOKEN
fi


if [ -n "$MYSQL_SERVER" ]; then
    ./openstack-config --set /etc/keystone/keystone.conf database connection mysql+pymysql://keystone:$ADMIN_PASSWORD@$MYSQL_SERVR/keystone
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

exec "$@"
