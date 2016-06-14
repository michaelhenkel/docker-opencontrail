#!/bin/bash

if [ -n "$HOST_IP" ]; then
    echo "my_ip = $HOST_IP" >> /etc/nova/nova.conf
fi
if [ -n "$VNC_PROXY" ]; then
    echo "vncserver_listen = $VNC_PROXY" >> /etc/nova/nova.conf
    echo "vncserver_proxyclient_address = $VNC_PROXY" >> /etc/nova/nova.conf
fi
if [ -n "$KEYSTONE_SERVER" ]; then
    echo "auth_strategy = keystone" >> /etc/nova/nova.conf
fi
if [ -n "$RABBIT_SERVER" ]; then
    echo "rpc_backend = rabbit" >> /etc/nova/nova.conf
fi
if [ -n "$HOST_IP" ]; then
    echo "my_ip = $HOST_IP" >> /etc/nova/nova.conf
fi
if [ -n "$KEYSTONE_SERVER" ]; then
    echo "[keystone_authtoken]" >> /etc/nova/nova.conf
    echo "auth_uri = http://$KEYSTONE_SERVER:5000" >> /etc/nova/nova.conf
    echo "auth_url = http://$KEYSTONE_SERVER:35357" >> /etc/nova/nova.conf
    echo "auth_plugin = password" >> /etc/nova/nova.conf
    echo "project_domain_id = default" >> /etc/nova/nova.conf
    echo "user_domain_id = default" >> /etc/nova/nova.conf
    echo "project_name = service" >> /etc/nova/nova.conf
    echo "username = nova" >> /etc/nova/nova.conf
    echo "password = $ADMIN_PASSWORD" >> /etc/nova/nova.conf
fi
if [ -n "$RABBIT_SERVER" ]; then
    echo "[oslo_messaging_rabbit]" >> /etc/nova/nova.conf
    echo "rabbit_host = $RABBIT_SERVER" >> /etc/nova/nova.conf
    echo "rabbit_password = guest" >> /etc/nova/nova.conf
fi
if [ -n "$MYSQL_SERVER" ]; then
    echo "[database]" >> /etc/nova/nova.conf
    echo "connection = mysql://nova:$ADMIN_PASSWORD@$MYSQL_SERVER/nova" >> /etc/nova/nova.conf
fi
if [ -n "$GLANCE_SERVER" ]; then
    echo "[glance]" >> /etc/nova/nova.conf
    echo "host = $GLANCE_SERVER" >> /etc/nova/nova.conf
fi

exec "$@"
