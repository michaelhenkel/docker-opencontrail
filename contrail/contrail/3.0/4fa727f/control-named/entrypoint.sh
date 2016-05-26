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
myip=`ifconfig $INTERFACE | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
sed -i 's/secret123/sHE1SM8nsySdgsoRxwARtA==/g' /etc/contrail/dns/contrail-named.conf
sed -i "s/allow { 127.0.0.1; }/allow { $myip; }/g" /etc/contrail/dns/contrail-named.conf
sed -i "s/inet 127.0.0.1/inet $myip/g" /etc/contrail/dns/contrail-named.conf
touch /etc/contrail/contrail-dns.conf
echo "[DEFAULT]" > /etc/contrail/contrail-dns.conf
echo "[DISCOVERY]" >> /etc/contrail/contrail-dns.conf
echo "[IFMAP]" >> /etc/contrail/contrail-dns.conf
./openstack-config --set /etc/contrail/contrail-dns.conf DEFAULT hostip $myip
if [ -n "$DISCOVERY_SERVER" ]; then
    ./openstack-config --set /etc/contrail/contrail-dns.conf DISCOVERY server $DISCOVERY_SERVER
fi
if [ -n "$IFMAP_SERVER" ]; then
    ./openstack-config --set /etc/contrail/contrail-dns.conf IFMAP server_url https://$IFMAP_SERVER:8443
fi
if [ -n "$IFMAP_USER" ]; then
    ./openstack-config --set /etc/contrail/contrail-dns.conf IFMAP user $IFMAP_USER.dns
fi
if [ -n "$IFMAP_PASSWORD" ]; then
    ./openstack-config --set /etc/contrail/contrail-dns.conf IFMAP password $IFMAP_PASSWORD.dns
fi
./openstack-config --set /etc/contrail/contrail-dns.conf DEFAULT rndc_secret sHE1SM8nsySdgsoRxwARtA==

exec "$@"
