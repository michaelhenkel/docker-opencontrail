#!/bin/bash


if [ -n "$KEYSTONE_SERVER" ]; then
  cat << EOF > /etc/contrail/contrail-keystone-auth.conf
[KEYSTONE]
auth_host=$KEYSTONE_SERVER
auth_protocol=http
auth_port=35357
admin_user=$ADMIN_USER
admin_password=$ADMIN_PASSWORD
admin_token=$ADMIN_TOKEN
admin_tenant_name=$ADMIN_TENANT
insecure=false
memcache_servers=$MEMCACHED_SERVER:11211
EOF

  cat << EOF > /etc/contrail/vnc_api_lib.ini
[global]
;WEB_SERVER = 127.0.0.1
;WEB_PORT = 9696  ; connection through quantum plugin

WEB_SERVER = 127.0.0.1
WEB_PORT = 8082 ; connection to api-server directly
BASE_URL = /
;BASE_URL = /tenants/infra ; common-prefix for all URLs

; Authentication settings (optional)
[auth]
AUTHN_TYPE = keystone
AUTHN_PROTOCOL = http
AUTHN_SERVER=$KEYSTONE_SERVER
AUTHN_PORT = 35357
AUTHN_URL = /v2.0/tokens
EOF
fi

if [ -n "$IFMAP_SERVER" ]; then
    sed -i "/\[DEFAULTS\]/a ifmap_password = schema-transformer" /etc/contrail/contrail-schema.conf
    sed -i "/\[DEFAULTS\]/a ifmap_username = schema-transformer" /etc/contrail/contrail-schema.conf
    sed -i "/\[DEFAULTS\]/a ifmap_server_ip = $IFMAP_SERVER" /etc/contrail/contrail-schema.conf
fi

if [ -n "$CASSANDRA_SERVER" ]; then
    IFS=',' read -ra NODE <<< "$CASSANDRA_SERVER"
    CASSANDRA_SERVER_LIST=""
    for i in "${NODE[@]}";do
        if [ -z $CASSANDRA_SERVER_LIST ]; then
            CASSANDRA_SERVER_LIST=`echo $i:9160`
        else
            CASSANDRA_SERVER_LIST=`echo $CASSANDRA_SERVER_LIST,$i:9160`
        fi
    done
    sed -i "/\[DEFAULTS\]/a cassandra_server_list = $CASSANDRA_SERVER_LIST" /etc/contrail/contrail-schema.conf
fi

if [ -n "$DISCOVERY_SERVER" ]; then
    sed -i "s/disc_server_ip = 127.0.0.1/disc_server_ip = $DISCOVERY_SERVER/g" /etc/contrail/contrail-schema.conf
fi

if [ -n "$CONFIG_API_SERVER" ]; then
    sed -i "/\[DEFAULTS\]/a api_server_ip = $CONFIG_API_SERVER" /etc/contrail/contrail-schema.conf
fi

if [ -n "$ZOOKEEPER_SERVER" ]; then
    IFS=',' read -ra NODE <<< "$ZOOKEEPER_SERVER"
    ZOOKEEPER_SERVER_LIST=""
    for i in "${NODE[@]}";do
        if [ -z $ZOOKEEPER_SERVER_LIST ]; then
            ZOOKEEPER_SERVER_LIST=`echo $i`
        else
            ZOOKEEPER_SERVER_LIST=`echo $ZOOKEEPER_SERVER_LIST $i`
        fi
    done
    sed -i "/\[DEFAULTS\]/a zk_server_ip = $ZOOKEEPER_SERVER_LIST" /etc/contrail/contrail-schema.conf
fi

exec "$@"
