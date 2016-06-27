#!/bin/bash

./openstack-config --set /etc/contrail/vnc_api_lib.ini auth AUTHN_SERVER $KEYSTONE_SERVER

touch /etc/contrail/contrail-keystone-auth.conf
if [ -n "$KEYSTONE_SERVER" ]; then
  ./openstack-config --set /etc/contrail/contrail-keystone-auth.conf KEYSTONE auth_host $KEYSTONE_SERVER
  ./openstack-config --set /etc/contrail/contrail-keystone-auth.conf KEYSTONE auth_protocol http
  ./openstack-config --set /etc/contrail/contrail-keystone-auth.conf KEYSTONE auth_port 35357
  ./openstack-config --set /etc/contrail/contrail-keystone-auth.conf KEYSTONE admin_user $ADMIN_USER
  ./openstack-config --set /etc/contrail/contrail-keystone-auth.conf KEYSTONE admin_password $ADMIN_PASSWORD
  ./openstack-config --set /etc/contrail/contrail-keystone-auth.conf KEYSTONE admin_token $ADMIN_TOKEN
  ./openstack-config --set /etc/contrail/contrail-keystone-auth.conf KEYSTONE admin_tenant_name $ADMIN_TENANT
  ./openstack-config --set /etc/contrail/contrail-keystone-auth.conf KEYSTONE insecure false
  ./openstack-config --set /etc/contrail/contrail-keystone-auth.conf KEYSTONE memcache_servers $MEMCACHED_SERVER:11211
fi

if [ -n "$DISCOVERY_SERVER" ]; then
    ./openstack-config --set /etc/contrail/contrail-control.conf DISCOVERY server $DISCOVERY_SERVER
fi

myip_ext=`ifconfig $INTERFACE_EXT | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
./openstack-config --set /etc/contrail/contrail-control.conf DEFAULT hostip $myip_ext

if [ -n "$IFMAP_USER" ]; then
    ./openstack-config --set /etc/contrail/contrail-control.conf IFMAP user $IFMAP_USER
fi

if [ -n "$IFMAP_PASSWORD" ]; then
    ./openstack-config --set /etc/contrail/contrail-control.conf IFMAP password $IFMAP_PASSWORD
fi

#if [ -n "$IFMAP_SERVER" ]; then
#    ./openstack-config --set /etc/contrail/contrail-control.conf IFMAP server_url https://$IFMAP_SERVER:8443
#fi
hname=`hostname`
myip_int=`ifconfig $INTERFACE_INT | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
/usr/sbin/contrail-provision-control --host_name $hname --host_ip $myip_ext --router_asn 64512 --api_server_ip $CONFIG_API_SERVER --api_server_port 8082 --oper add --admin_user $ADMIN_USER --admin_password $ADMIN_PASSWORD --admin_tenant_name $ADMIN_TENANT

exec "$@"
