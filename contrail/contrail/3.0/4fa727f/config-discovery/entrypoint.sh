#!/bin/bash


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
    sed -i "s/cassandra_server_list = 127.0.0.1:9160/cassandra_server_list = $CASSANDRA_SERVER_LIST/g" /etc/contrail/contrail-discovery.conf
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
    sed -i "s/zk_server_ip=127.0.0.1/zk_server_ip = $ZOOKEEPER_SERVER_LIST/g" /etc/contrail/contrail-discovery.conf
fi

exec "$@"
