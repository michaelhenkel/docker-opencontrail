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

exec "$@"
