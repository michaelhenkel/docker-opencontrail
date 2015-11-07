#!/bin/bash

if [ -n "$DISCOVERY_SERVER" ]; then
    ./openstack-config --set /etc/contrail/contrail-control-nodemgr.conf DISCOVERY server $DISCOVERY_SERVER 
fi
exec "$@"
