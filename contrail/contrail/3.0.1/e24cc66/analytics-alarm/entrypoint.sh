#!/bin/bash

./openstack-config --set /etc/contrail/vnc_api_lib.ini auth AUTHN_SERVER $KEYSTONE_SERVER

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
    ./openstack-config --set /etc/contrail/contrail-alarm-gen.conf DISCOVERY disc_server_ip $DISCOVERY_SERVER
fi

myip=`ifconfig $INTERFACE | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
./openstack-config --set /etc/contrail/contrail-alarm-gen.conf DEFAULTS host_ip $myip

if [ -n "$ZOOKEEPER_SERVER" ]; then
    IFS=',' read -ra NODE <<< "$ZOOKEEPER_SERVER"
    ZOOKEEPER_SERVER_LIST=""
    for i in "${NODE[@]}";do
        if [ -z $ZOOKEEPER_SERVER_LIST ]; then
            ZOOKEEPER_SERVER_LIST=`echo $i:2181`
        else
            ZOOKEEPER_SERVER_LIST=`echo $ZOOKEEPER_SERVER_LIST $i:2181`
        fi
    done
    ./openstack-config --set /etc/contrail/contrail-alarm-gen.conf DEFAULTS zk_list $ZOOKEEPER_SERVER_LIST
fi

if [ -n "$ZOOKEEPER_SERVER" ]; then
    IFS=',' read -ra NODE <<< "$ZOOKEEPER_SERVER"
    KAFKA_SERVER_LIST=""
    for i in "${NODE[@]}";do
        if [ -z $KAFKA_SERVER_LIST ]; then
            KAFKA_SERVER_LIST=`echo $i:9092`
        else
            KAFKA_SERVER_LIST=`echo $KAFKA_SERVER_LIST $i:9092`
        fi
    done
    ./openstack-config --set /etc/contrail/contrail-alarm-gen.conf DEFAULTS kafka_broker_list $KAFKA_SERVER_LIST
fi

if [ -n "$ANALYTICS_REDIS_SERVER" ]; then
    ./openstack-config --set /etc/contrail/contrail-alarm-gen.conf REDIS redis_server_ip $ANALYTICS_REDIS_SERVER
fi



exec "$@"
