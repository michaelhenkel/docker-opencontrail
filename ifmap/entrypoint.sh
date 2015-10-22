#!/bin/bash

if [ -n "$CTRL_NODES" ]; then
    IFS=',' read -ra NODE <<< "$CTRL_NODES"
    for i in "${NODE[@]}";do
        echo $i:$i >> /etc/ifmap-server/basicauthusers.properties
        echo $i.dns:$i.dns >> /etc/ifmap-server/basicauthusers.properties
    done
fi

exec "$@"
