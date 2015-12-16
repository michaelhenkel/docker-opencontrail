#!/bin/bash

if [ -n "$IFMAP_USER" ]; then
    IFS=',' read -ra NODE <<< "$IFMAP_USER"
    for i in "${NODE[@]}";do
        echo $i:$i >> /etc/ifmap-server/basicauthusers.properties
        echo $i.dns:$i.dns >> /etc/ifmap-server/basicauthusers.properties
    done
fi

exec "$@"
