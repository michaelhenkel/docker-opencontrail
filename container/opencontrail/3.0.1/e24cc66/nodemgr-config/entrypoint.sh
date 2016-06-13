#!/bin/bash
touch /etc/contrail/contrail-config-nodemgr.conf
if [ -n "$DISCOVERY_SERVER" ]; then
    ./openstack-config --set /etc/contrail/contrail-config-nodemgr.conf DISCOVERY server $DISCOVERY_SERVER
fi
exec "$@"
