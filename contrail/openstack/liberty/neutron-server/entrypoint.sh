#!/bin/bash
if [ -n $CONFIG_API_SERVER ];then
    ./openstack-config --set /etc/neutron/neutron.conf DEFAULT core_plugin neutron_plugin_contrail.plugins.opencontrail.contrail_plugin.NeutronPluginContrailCoreV2
    ./openstack-config --set /etc/neutron/neutron.conf DEFAULT api_extensions_path /usr/lib/python2.7/dist-packages/neutron_plugin_contrail/extensions/
#    ./openstack-config --set /etc/neutron/neutron.conf DEFAULT service_plugins neutron_plugin_contrail.plugins.opencontrail.loadbalancer.plugin.LoadBalancerPlugin
    ./openstack-config --set /etc/neutron/neutron.conf quotas quota_driver neutron_plugin_contrail.plugins.opencontrail.quota.driver.QuotaDriver
    ./openstack-config --set /etc/neutron/neutron.conf quotas quota_network  -1
    ./openstack-config --set /etc/neutron/neutron.conf quotas quota_subnet  -1
    ./openstack-config --set /etc/neutron/neutron.conf quotas quota_port  -1
#    ./openstack-config --set /etc/neutron/neutron.conf service_providers service_provider LOADBALANCER:Opencontrail:neutron_plugin_contrail.plugins.opencontrail.loadbalancer.driver.OpencontrailLoadbalancerDriver:default
    ./openstack-config --set /etc/neutron/plugins/opencontrail/ContrailPlugin.ini APISERVER api_server_ip $CONFIG_API_SERVER
    ./openstack-config --set /etc/neutron/plugins/opencontrail/ContrailPlugin.ini APISERVER api_server_port 8082
    ./openstack-config --set /etc/neutron/plugins/opencontrail/ContrailPlugin.ini APISERVER multi_tenancy True
    ./openstack-config --set /etc/neutron/plugins/opencontrail/ContrailPlugin.ini APISERVER contrail_extensions ipam:neutron_plugin_contrail.plugins.opencontrail.contrail_plugin_ipam.NeutronPluginContrailIpam,policy:neutron_plugin_contrail.plugins.opencontrail.contrail_plugin_policy.NeutronPluginContrailPolicy,route-table:neutron_plugin_contrail.plugins.opencontrail.contrail_plugin_vpc.NeutronPluginContrailVpc,contrail:None
    ./openstack-config --set /etc/neutron/plugins/opencontrail/ContrailPlugin.ini COLLECTOR analytics_api_ip $ANALYTICS_SERVER
    ./openstack-config --set /etc/neutron/plugins/opencontrail/ContrailPlugin.ini COLLECTOR analytics_api_port 9081
    ./openstack-config --set /etc/neutron/plugins/opencontrail/ContrailPlugin.ini KEYSTONE auth_url http://$KEYSTONE_SERVER:35357/v2.0
    ./openstack-config --set /etc/neutron/plugins/opencontrail/ContrailPlugin.ini KEYSTONE admin_token $ADMIN_TOKEN
    ./openstack-config --set /etc/neutron/plugins/opencontrail/ContrailPlugin.ini KEYSTONE admin_user $ADMIN_USER
    ./openstack-config --set /etc/neutron/plugins/opencontrail/ContrailPlugin.ini KEYSTONE admin_password $ADMIN_PASSWORD
    ./openstack-config --set /etc/neutron/plugins/opencontrail/ContrailPlugin.ini KEYSTONE admin_tenant_name $ADMIN_PASSWORD
fi
if [ -n "$KEYSTONE_SERVER" ]; then
    ./openstack-config --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_status_changes True
    ./openstack-config --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_data_changes True
    ./openstack-config --set /etc/neutron/neutron.conf DEFAULT nova_url http://$KEYSTONE_SERVER:8774/v2
    ./openstack-config --set /etc/neutron/neutron.conf DEFAULT auth_strategy keystone
    ./openstack-config --set /etc/neutron/neutron.conf keystone_authtoken admin_tenant_name $ADMIN_TENANT
    ./openstack-config --set /etc/neutron/neutron.conf keystone_authtoken admin_user $ADMIN_USER
    ./openstack-config --set /etc/neutron/neutron.conf keystone_authtoken admin_password $ADMIN_PASSWORD
    ./openstack-config --set /etc/neutron/neutron.conf keystone_authtoken auth_host $KEYSTONE_SERVER
    ./openstack-config --set /etc/neutron/neutron.conf keystone_authtoken port 35357
    ./openstack-config --set /etc/neutron/neutron.conf keystone_authtoken admin_token $ADMIN_TOKEN
    ./openstack-config --set /etc/neutron/neutron.conf keystone_authtoken insecure false
    ./openstack-config --set /etc/neutron/neutron.conf keystone_authtoken auth_protocol http
    ./openstack-config --del /etc/neutron/neutron.conf keystone_authtoken revocation_cache_time
    ./openstack-config --set /etc/neutron/neutron.conf keystone_authtoken auth_uri http://$KEYSTONE_SERVER:5000
    ./openstack-config --set /etc/neutron/neutron.conf keystone_authtoken auth_url http://$KEYSTONE_SERVER:35357
    ./openstack-config --set /etc/neutron/neutron.conf keystone_authtoken auth_plugin password
    ./openstack-config --set /etc/neutron/neutron.conf keystone_authtoken project_domain_id default
    ./openstack-config --set /etc/neutron/neutron.conf keystone_authtoken user_domain_id default
    ./openstack-config --set /etc/neutron/neutron.conf keystone_authtoken project_name service
    ./openstack-config --set /etc/neutron/neutron.conf keystone_authtoken username neutron
    ./openstack-config --set /etc/neutron/neutron.conf keystone_authtoken password $ADMIN_PASSWORD
    ./openstack-config --set /etc/neutron/neutron.conf nova auth_url http://$KEYSTONE_SERVER:35357
    ./openstack-config --set /etc/neutron/neutron.conf nova auth_plugin password
    ./openstack-config --set /etc/neutron/neutron.conf nova project_domain_id default
    ./openstack-config --set /etc/neutron/neutron.conf nova user_domain_id default
    ./openstack-config --set /etc/neutron/neutron.conf nova region_name RegionOne
    ./openstack-config --set /etc/neutron/neutron.conf nova project_name service
    ./openstack-config --set /etc/neutron/neutron.conf nova username nova
    ./openstack-config --set /etc/neutron/neutron.conf nova password $ADMIN_PASSWORD
fi
if [ -n "$RABBIT_SERVER" ]; then
    ./openstack-config --set /etc/neutron/neutron.conf DEFAULT rpc_backend rabbit
    ./openstack-config --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_host $RABBIT_SERVER
    ./openstack-config --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_password guest
fi
if [ -n "$HOST_IP" ]; then
    ./openstack-config --set /etc/neutron/neutron.conf DEFAULT my_ip $HOST_IP
fi
#if [ -n "$MYSQL_SERVER" ]; then
#    ./openstack-config --set /etc/neutron/neutron.conf database connection mysql://neutron:$ADMIN_PASSWORD@$MYSQL_SERVER/neutron
#fi

exec "$@"
