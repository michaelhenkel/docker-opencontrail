# docker-opencontrail

This guide explains how Docker containers can be used as a portable and Linux OS agnostic  
OpenStack/OpenContrail deployment system.  
The goal is to run a single process per container without needing an init system  
inside the container. This works for all processes besides Kafka/Zookeeper  
which run both inside the same container using supervisord as the init system.

# Components  
  OpenStack and OpenContrail require a number of components which can be grouped together:

  - Common (components shared between OpenStack and OpenContrail)  
    - Keystone
    - RabbitMQ
    - Redis
    - Memcached  

  - OpenStack (components required by OpenStack)
    - Nova  
      - api
      - cert
      - compute
      - conductor
      - consoleauth
      - scheduler
      - novncproxy
    - Neutron
      - server
    - Cinder
      - api
      - scheduler
    - Glance
      - registry
      - api
    - Libvirt

  - OpenContrail (components required by OpenContrail)
    - Database
      - cassandra
      - zookeeper
      - kafka
    - Config
      - api
      - scv-monitor
      - schema
      - discovery
      - device-manager
    - Analytics
      - api
      - alarm
      - snmp
      - query
      - collector
      - topology
    - Control
      - control
      - named
      - dns
    - Webui
      - job
      - server
    - Ifmap
    

The interfaces between OpenStack and OpenContrail are mainly the neutron-server,  
nova-api and nova-compute containers. Those need OpenContrail libraries installed.  
All other OpenStack related containers are off the shelf.  
Docker allows to apply arbitray labels to images as some sort of metadata which  
makes it easy to use the above structure to identify container groupings.  


This label filter shows all OpenContrail relevant images:  
```
root# docker images --filter label=net.juniper.contrail
REPOSITORY                             TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
localhost:5100/vrouter-agent           contrail-3.0-2668   ed7662557493        11 hours ago        566.8 MB
localhost:5100/cassandra               contrail-3.0-2668   06e371fb7560        12 hours ago        364.1 MB
localhost:5100/keystone                contrail-3.0-2668   767c649a62ab        12 hours ago        372.5 MB
localhost:5100/memcached               contrail-3.0-2668   b7b4bc32b7bd        13 hours ago        132.2 MB
localhost:5100/rabbitmq                contrail-3.0-2668   95db8b5bfaea        13 hours ago        182.9 MB
localhost:5100/redis                   contrail-3.0-2668   e1aba142d899        13 hours ago        109.2 MB
localhost:5100/zookeeper               contrail-3.0-2668   31f8451c0729        13 hours ago        421.6 MB
localhost:5100/ifmap                   contrail-3.0-2668   6634c685b73d        13 hours ago        328.6 MB
localhost:5100/config-svc-monitor      contrail-3.0-2668   cca0a05e2eec        16 hours ago        471.3 MB
localhost:5100/config-schema           contrail-3.0-2668   f632849389dd        16 hours ago        471.3 MB
localhost:5100/config-discovery        contrail-3.0-2668   9066abc22b50        16 hours ago        471.3 MB
localhost:5100/config-device-manager   contrail-3.0-2668   8c8f62de6016        16 hours ago        471.3 MB
localhost:5100/config-api              contrail-3.0-2668   827228f8eac7        16 hours ago        471.3 MB
localhost:5100/webui-server            contrail-3.0-2668   54e9fba13435        16 hours ago        458.9 MB
localhost:5100/webui-job               contrail-3.0-2668   853c2a421474        16 hours ago        458.9 MB
localhost:5100/analytics-topology      contrail-3.0-2668   6daffa7a9a0f        16 hours ago        444.5 MB
localhost:5100/analytics-snmp          contrail-3.0-2668   bdc060fffb94        16 hours ago        444.5 MB
localhost:5100/analytics-query         contrail-3.0-2668   d5dd077f890d        16 hours ago        444.5 MB
localhost:5100/analytics-collector     contrail-3.0-2668   97977ae0218d        16 hours ago        444.5 MB
localhost:5100/analytics-api           contrail-3.0-2668   6c8e23a01263        16 hours ago        444.5 MB
localhost:5100/analytics-alarm         contrail-3.0-2668   6eba0d2fad7a        16 hours ago        444.5 MB
localhost:5100/control-named           contrail-3.0-2668   58c66578c4ef        16 hours ago        573 MB
localhost:5100/control-dns             contrail-3.0-2668   7131c438cd35        16 hours ago        573 MB
localhost:5100/control-control
```
 
The filter can be more granular by filtering for a subcategory:
```
root# docker images --filter label=net.juniper.contrail=config
REPOSITORY                             TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
localhost:5100/ifmap                   contrail-3.0-2668   6634c685b73d        13 hours ago        328.6 MB
localhost:5100/config-svc-monitor      contrail-3.0-2668   cca0a05e2eec        16 hours ago        471.3 MB
localhost:5100/config-schema           contrail-3.0-2668   f632849389dd        16 hours ago        471.3 MB
localhost:5100/config-discovery        contrail-3.0-2668   9066abc22b50        16 hours ago        471.3 MB
localhost:5100/config-device-manager   contrail-3.0-2668   8c8f62de6016        16 hours ago        471.3 MB
localhost:5100/config-api              contrail-3.0-2668   827228f8eac7        16 hours ago        471.3 MB
```

