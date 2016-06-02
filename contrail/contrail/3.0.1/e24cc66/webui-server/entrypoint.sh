#!/bin/bash

if [ -n "$KEYSTONE_SERVER" ]; then

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

cat << EOF > /etc/contrail/contrail-webui-userauth.js
var auth = {};
auth.admin_user = '$ADMIN_USER';
auth.admin_password = '$ADMIN_PASSWORD';
auth.admin_token = '$ADMIN_TOKEN';
auth.admin_tenant_name = '$ADMIN_TENANT';

module.exports = auth;
EOF

if [ -n "$NEUTRON_SERVER" ]; then
    sed -i "s/config.networkManager.ip = '127.0.0.1';/config.networkManager.ip = '$NEUTRON_SERVER';/g" /etc/contrail/config.global.js
fi

if [ -n "$GLANCE_API_SERVER" ]; then
    sed -i "s/config.imageManager.ip = '127.0.0.1';/config.imageManager.ip = '$GLANCE_API_SERVER';/g" /etc/contrail/config.global.js
fi

if [ -n "$NOVA_API_SERVER" ]; then
    sed -i "s/config.computeManager.ip = '127.0.0.1';/config.computeManager.ip = '$NOVA_API_SERVER';/g" /etc/contrail/config.global.js
fi

if [ -n "$KEYSTONE_SERVER" ]; then
    sed -i "s/config.identityManager.ip = '127.0.0.1';/config.identityManager.ip = '$KEYSTONE_SERVER';/g" /etc/contrail/config.global.js
fi

if [ -n "$CINDER_SERVER" ]; then
    sed -i "s/config.storageManager.ip = '127.0.0.1';/config.storageManager.ip = '$CINDER_SERVER';/g" /etc/contrail/config.global.js
fi

if [ -n "$CONFIG_API_SERVER" ]; then
    sed -i "s/config.cnfg.server_ip = '127.0.0.1';/config.cnfg.server_ip = '$CONFIG_API_SERVER';/g" /etc/contrail/config.global.js
fi

if [ -n "$ANALYTICS_API_SERVER" ]; then
    sed -i "s/config.analytics.server_ip = '127.0.0.1';/config.analytics.server_ip = '$ANALYTICS_API_SERVER';/g" /etc/contrail/config.global.js
fi
sed -i "s#config.featurePkg.webController.path = '/usr/src/contrail/contrail-web-controller';#config.featurePkg.webController.path = '/var/lib/contrail-webui/contrail-web-controller';#g" /etc/contrail/config.global.js

#if [ -n "$WEBUI_SERVER" ]; then
#    sed -i "s/config.jobServer.server_ip = '127.0.0.1';/config.jobServer.server_ip = '$WEBUI_SERVER';/g" /etc/contrail/config.global.js
#fi

if [ -n "$REDIS_SERVER" ]; then
    sed -i "s/config.redis_server_ip = '127.0.0.1';/config.redis_server_ip = '$REDIS_SERVER';/g" /etc/contrail/config.global.js
fi


if [ -n "$CASSANDRA_SERVER" ]; then
    IFS=',' read -ra NODE <<< "$CASSANDRA_SERVER"
    CASSANDRA_SERVER_LIST=""
    for i in "${NODE[@]}";do
        if [ -z $CASSANDRA_SERVER_LIST ]; then
            CASSANDRA_SERVER_LIST=`echo $i`
        else
            CASSANDRA_SERVER_LIST=`echo $CASSANDRA_SERVER_LIST,$i`
        fi
    done
    CASSANDRA_SERVER_LIST_STRING=`echo [\'$CASSANDRA_SERVER_LIST\']`
    sed -i "s/config.cassandra.server_ips = \['127.0.0.1'\];/config.cassandra.server_ips = $CASSANDRA_SERVER_LIST_STRING/g" /etc/contrail/config.global.js
fi

exec "$@"
