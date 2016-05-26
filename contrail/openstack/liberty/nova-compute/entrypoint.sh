#!/bin/bash
myip=`ifconfig $INTERFACE | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
./openstack-config --set /etc/nova/nova.conf DEFAULT my_ip $myip
if [ -n "$VNC_PROXY" ]; then
    ./openstack-config --set /etc/nova/nova.conf DEFAULT vncserver_listen $myip
    ./openstack-config --set /etc/nova/nova.conf DEFAULT vncserver_proxyclient_address $VNC_PROXY
fi
if [ -n "$NEUTRON_SERVER" ]; then
    ./openstack-config --set /etc/nova/nova.conf neutron admin_auth_url http://$KEYSTONE_SERVER:35357/v2.0
    ./openstack-config --set /etc/nova/nova.conf neutron extension_sync_interval 600
    ./openstack-config --set /etc/nova/nova.conf neutron admin_username neutron
    ./openstack-config --set /etc/nova/nova.conf neutron admin_tenant_name service
    ./openstack-config --set /etc/nova/nova.conf neutron admin_password $ADMIN_PASSWORD
    ./openstack-config --set /etc/nova/nova.conf neutron url_timeout 30
    ./openstack-config --set /etc/nova/nova.conf neutron default_tenant_id $ADMIN_TENANT
    ./openstack-config --set /etc/nova/nova.conf neutron url http://$NEUTRON_SERVER:9696
    ./openstack-config --set /etc/nova/nova.conf neutron service_metadata_proxy True
    
fi
if [ -n "$KEYSTONE_SERVER" ]; then
    ./openstack-config --set /etc/nova/nova.conf DEFAULT auth_strategy keystone
#    ./openstack-config --set /etc/nova/nova.conf DEFAULT network_api_class nova_contrail_vif.contrailvif.ContrailNetworkAPI
    ./openstack-config --del /etc/nova/nova.conf keystone_authtoken identity_uri
    ./openstack-config --del /etc/nova/nova.conf keystone_authtoken admin_tenant_name
    ./openstack-config --del /etc/nova/nova.conf keystone_authtoken admin_user
    ./openstack-config --del /etc/nova/nova.conf keystone_authtoken admin_password
    ./openstack-config --del /etc/nova/nova.conf keystone_authtoken revocation_cache_time
    ./openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_uri http://$KEYSTONE_SERVER:5000
    ./openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_url http://$KEYSTONE_SERVER:35357
    ./openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_plugin password
    ./openstack-config --set /etc/nova/nova.conf keystone_authtoken project_domain_id default
    ./openstack-config --set /etc/nova/nova.conf keystone_authtoken user_domain_id default
    ./openstack-config --set /etc/nova/nova.conf keystone_authtoken project_name service
    ./openstack-config --set /etc/nova/nova.conf keystone_authtoken username nova
    ./openstack-config --set /etc/nova/nova.conf keystone_authtoken password $ADMIN_PASSWORD
fi
if [ -n "$RABBIT_SERVER" ]; then
    ./openstack-config --set /etc/nova/nova.conf DEFAULT rpc_backend rabbit
    ./openstack-config --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_host $RABBIT_SERVER
    ./openstack-config --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_password guest
fi
if [ -n "$MYSQL_SERVER" ]; then
    ./openstack-config --set /etc/nova/nova.conf database connection mysql://nova:$ADMIN_PASSWORD@$MYSQL_SERVER/nova
fi
if [ -n "$GLANCE_API_SERVER" ]; then
    ./openstack-config --set /etc/nova/nova.conf glance host $GLANCE_API_SERVER
fi
./openstack-config --set /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp
./openstack-config --set /etc/nova/nova.conf DEFAULT compute_driver libvirt.LibvirtDriver
./openstack-config --set /etc/nova/nova.conf DEFAULT libvirt_vif_driver nova_contrail_vif.contrailvif.VRouterVIFDriver
./openstack-config --set /etc/nova/nova.conf DEFAULT network_api_class nova.network.neutronv2.api.API
./openstack-config --set /etc/nova/nova.conf libvirt virt_type kvm
./openstack-config --set /etc/nova/nova.conf libvirt connection_uri qemu+tcp://$myip/system
./openstack-config --set /etc/nova/nova.conf libvirt live_migration_uri qemu+tcp://$myip/system
exec "$@"
