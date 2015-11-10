# docker-opencontrail

This guide explains how Docker containers can be used as a portable and Linux OS agnostic  
OpenStack/OpenContrail deployment system.  

# Components  
  OpenStack and OpenContrail require a number of components which can be grouped together:

  - Common (components shared between OpenStack and OpenContrail)  
    - Keystone
    - RabbitMQ
    - Redis
    - Memcached  

  - OpenStack
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

  - OpenContrail
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
    
