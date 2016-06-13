#!/bin/bash
cat << EOF > /opencontrail-docker-libnetwork/opencontrail.conf
---
keystone_server: $KEYSTONE_SERVER
api_server: $CONFIG_API_SERVER
api_port: '8082'
admin_user: $ADMIN_USER
admin_password: $ADMIN_PASSWORD
admin_tenant: $ADMIN_TENANT
socketpath: $SOCKET_PATH
scope: $SCOPE
DEBUG: $DEBUG
EOF

exec "$@"
