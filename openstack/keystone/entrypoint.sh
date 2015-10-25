#!/bin/bash

if [ -n "$ADMIN_TOKEN" ]; then
    sed -i "s/#admin_token = ADMIN/admin_token = $ADMIN_TOKEN/g" /etc/keystone/keystone.conf
fi

if [ -n "$MYSQL_SERVER" ]; then
    sed -i "s/connection = sqlite:\/\/\/\/var\/lib\/keystone\/keystone.db/connection = mysql:\/\/keystone:$ADMIN_PASSWORD@$MYSQL_SERVER\/keystone/g" /etc/keystone/keystone.conf
fi

if [ -n "$MEMCACHED_SERVER" ]; then
    sed -i "s/#servers = localhost:11211/servers = $MEMCACHED_SERVER:11211/g" /etc/keystone/keystone.conf
fi

sed -i "s/#driver = keystone.contrib.revoke.backends.sql.Revoke/driver = keystone.contrib.revoke.backends.sql.Revoke/g" /etc/keystone/keystone.conf
sed -i "s/#driver = keystone.token.persistence.backends.sql.Token/driver = keystone.token.persistence.backends.memcache.Token/g" /etc/keystone/keystone.conf

exec "$@"
