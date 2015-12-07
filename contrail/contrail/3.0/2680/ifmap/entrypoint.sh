#!/bin/bash

if [ -n "$CONTROL_SERVER" ]; then
    IFS=',' read -ra NODE <<< "$CONTROL_SERVER"
    for i in "${NODE[@]}";do
        echo $i:$i >> /etc/ifmap-server/basicauthusers.properties
        echo $i.dns:$i.dns >> /etc/ifmap-server/basicauthusers.properties
    done
fi

exec "$@"
