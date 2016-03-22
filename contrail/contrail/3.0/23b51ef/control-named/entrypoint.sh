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
sed -i 's/secret123/sHE1SM8nsySdgsoRxwARtA==/g' /etc/contrail/dns/contrail-named.conf
sed -i '/pid-file/a empty-zones-enable no;' /etc/contrail/dns/contrail-named.conf
sed -i '/pid-file/a listen-on port 53 { any; };' /etc/contrail/dns/contrail-named.conf
sed -i '/pid-file/a allow-query { any; };' /etc/contrail/dns/contrail-named.conf
sed -i '/pid-file/a allow-recursion { any; };' /etc/contrail/dns/contrail-named.conf
sed -i '/pid-file/a allow-query-cache { any; };' /etc/contrail/dns/contrail-named.conf
sed -i '/pid-file/a max-cache-size 100M;' /etc/contrail/dns/contrail-named.conf
sed -i '/pid-file/a session-keyfile "/etc/contrail/dns/session.key";' /etc/contrail/dns/contrail-named.conf

exec "$@"
