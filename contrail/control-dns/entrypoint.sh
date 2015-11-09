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
touch /etc/contrail/dns/contrail-dns.conf
echo "[DEFAULTS]" > /etc/contrail/dns/contrail-dns.conf
echo "[DISCOVERY]" >> /etc/contrail/dns/contrail-dns.conf
echo "[IFMAP]" >> /etc/contrail/dns/contrail-dns.conf

if [ -n "$HOST_IP" ]; then
    sed -i "/\[DEFAULTS\]/a hostip = $HOST_IP" /etc/contrail/dns/contrail-dns.conf
fi

if [ -n "$DISCOVERY_SERVER" ]; then
    sed -i "/\[DISCOVERY\]/a server = $DISCOVERY_SERVER" /etc/contrail/dns/contrail-dns.conf
fi

if [ -n "$IFMAP_USER" ]; then
    sed -i "/\[IFMAP\]/a user = $IFMAP_USER" /etc/contrail/dns/contrail-dns.conf
fi

if [ -n "$IFMAP_PASSWORD" ]; then
    sed -i "/\[IFMAP\]/a password = $IFMAP_PASSWORD" /etc/contrail/dns/contrail-dns.conf
fi

exec "$@"
