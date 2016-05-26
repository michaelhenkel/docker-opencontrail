#!/bin/bash

myip=`ifconfig $INTERFACE | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
./openstack-config --set /etc/nova/nova.conf DEFAULT glance_api_servers http://$GLANCE_API_SERVER:9292
./openstack-config --set /etc/nova/nova.conf DEFAULT memcached_servers $MEMCACHED_SERVER:11211
./openstack-config --set /etc/nova/nova.conf DEFAULT novncproxy_host $myip
./openstack-config --set /etc/nova/nova.conf DEFAULT network_api_class nova.network.neutronv2.api.API
./openstack-config --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
./openstack-config --set /etc/nova/nova.conf DEFAULT auth_strategy keystone
./openstack-config --set /etc/nova/nova.conf DEFAULT rpc_backend rabbit
./openstack-config --set /etc/nova/nova.conf vnc novncproxy_base_url http://$myip:5999/vnc_auto.html
./openstack-config --set /etc/nova/nova.conf vnc vncserver_listen $VNC_PROXY
./openstack-config --set /etc/nova/nova.conf vnc vncserver_proxyclient_address $VNC_PROXY
./openstack-config --set /etc/nova/nova.conf database connection mysql://nova:$ADMIN_PASSWORD@$MYSQL_SERVER/nova
./openstack-config --set /etc/nova/nova.conf neutron service_metadata_proxy True
./openstack-config --set /etc/nova/nova.conf neutron auth_strategy keystone
./openstack-config --set /etc/nova/nova.conf neutron url http://$NEUTRON_SERVER:9696
./openstack-config --set /etc/nova/nova.conf neutron url_timeout 30
./openstack-config --set /etc/nova/nova.conf neutron admin_tenant_name service
./openstack-config --set /etc/nova/nova.conf neutron default_tenant_id default
./openstack-config --set /etc/nova/nova.conf neutron region_name RegionOne
./openstack-config --set /etc/nova/nova.conf neutron admin_username neutron
./openstack-config --set /etc/nova/nova.conf neutron admin_password contrail123
./openstack-config --set /etc/nova/nova.conf neutron admin_auth_url http://$KEYSTONE_SERVER:35357/v2.0
./openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_uri http://$KEYSTONE_SERVER:5000/
./openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_url http://$KEYSTONE_SERVER:35357
./openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_plugin password
./openstack-config --set /etc/nova/nova.conf keystone_authtoken project_domain_id default
./openstack-config --set /etc/nova/nova.conf keystone_authtoken user_domain_id default
./openstack-config --set /etc/nova/nova.conf keystone_authtoken project_name service
./openstack-config --set /etc/nova/nova.conf keystone_authtoken username nova
./openstack-config --set /etc/nova/nova.conf keystone_authtoken password contrail123
./openstack-config --set /etc/nova/nova.conf glance host $GLANCE_API_SERVER
./openstack-config --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_host $RABBIT_SERVER
./openstack-config --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_password guest

mysql -h $MYSQL_SERVER -u root -p$ADMIN_PASSWORD -e "SHOW DATABASES;" |grep nova
if [ $? -eq 1 ]; then
  while ! nc -z $MYSQL_SERVER 3306; do
    sleep 0.1
  done
  mysql -h $MYSQL_SERVER -u root -p$ADMIN_PASSWORD -e "CREATE DATABASE nova;"
  mysql -h $MYSQL_SERVER -u root -p$ADMIN_PASSWORD -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' \
        IDENTIFIED BY '$ADMIN_PASSWORD';"
  mysql -h $MYSQL_SERVER -u root -p$ADMIN_PASSWORD -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' \
        IDENTIFIED BY '$ADMIN_PASSWORD';"
fi
db_version=`nova-manage db version`
if [ $db_version -eq 0 ]; then
  nova-manage db sync
fi
#/usr/bin/python /usr/bin/nova-api &
#while ! nc -z localhost 8774; do
#  sleep 0.1
#done
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
#kill -9 $(pidof python)
exec "$@"
