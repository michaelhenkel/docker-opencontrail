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
if [ -n "$GLANCE_API_SERVER" ]; then
    echo "[glance]" >> /etc/nova/nova.conf
    echo "host = $GLANCE_API_SERVER" >> /etc/nova/nova.conf
fi
echo "[oslo_concurrency]" >> /etc/nova/nova.conf
echo "lock_path = /var/lib/nova/tmp" >> /etc/nova/nova.conf
db_version=`nova-manage db_version`
if [ $db_version -eq 0 ]; then
  nova-manage db_sync
fi
/usr/bin/python /usr/bin/nova-api &
while ! nc -z localhost 8774; do
  sleep 0.1
done
while ! nc -z $KEYSTONE_SERVER 35357; do
  sleep 0.1
done
openstack user show nova
if [ $? -eq 1 ]; then
  openstack user create --password $ADMIN_PASSWORD nova
  openstack role add --project service --user nova $ADMIN_USER
fi
openstack service show nova
if [ $? -eq 1 ]; then
  openstack service create --name nova --description "OpenStack Image service" compute
fi
openstack endpoint show nova
if [ $? -eq 1 ]; then
  openstack endpoint create --region RegionOne compute \
    --publicurl http://$NOVA_API_SERVER:8774/v2/%\(tenant_id\)s \
    --adminurl http://$NOVA_API_SERVER:8774/v2/%\(tenant_id\)s \
    --internalurl http://$NOVA_API_SERVER:8774/v2/%\(tenant_id\)s
fi
kill -9 $(pidof python)
exec "$@"
