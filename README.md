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


This label filter shows all OpenContrail relevant container images:  
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

Each container image has a second classifier indicating if it runs on a compute or controller node:
```
root# docker images --filter label=net.juniper.node=controller
REPOSITORY                             TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
localhost:5100/cassandra               contrail-3.0-2668   06e371fb7560        13 hours ago        364.1 MB
localhost:5100/keystone                contrail-3.0-2668   767c649a62ab        13 hours ago        372.5 MB
localhost:5100/memcached               contrail-3.0-2668   b7b4bc32b7bd        13 hours ago        132.2 MB
localhost:5100/redis                   contrail-3.0-2668   e1aba142d899        13 hours ago        109.2 MB
localhost:5100/zookeeper               contrail-3.0-2668   31f8451c0729        14 hours ago        421.6 MB
localhost:5100/ifmap                   contrail-3.0-2668   6634c685b73d        14 hours ago        328.6 MB
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
localhost:5100/nova-scheduler          contrail-3.0-2668   803a6e3fe803        16 hours ago        562.9 MB
localhost:5100/nova-novncproxy         contrail-3.0-2668   78e7244749ad        16 hours ago        562.9 MB
localhost:5100/nova-consoleauth        contrail-3.0-2668   3ea7536356c2        16 hours ago        562.9 MB
localhost:5100/nova-conductor          contrail-3.0-2668   389fa7181601        16 hours ago        562.9 MB
localhost:5100/nova-cert               contrail-3.0-2668   9685ee342968        16 hours ago        562.9 MB
localhost:5100/nova-api                contrail-3.0-2668   abda305f0612        16 hours ago        562.9 MB
localhost:5100/control-named           contrail-3.0-2668   58c66578c4ef        16 hours ago        573 MB
localhost:5100/control-dns             contrail-3.0-2668   7131c438cd35        16 hours ago        573 MB
localhost:5100/control-control         contrail-3.0-2668   09be1889a7e1        16 hours ago        573 MB
localhost:5100/neutron-server          contrail-3.0-2668   becd59c6add2        18 hours ago        377.6 MB
```

# Container image build process

Containers required to run OpenContrail or containing OpenContrail libraries are located  
in the contrail directory:  

```
root:~/Dockerfiles/contrail# ll
total 156
drwxr-xr-x  2 root root 4096 Nov  9 07:39 analytics/
drwxr-xr-x  2 root root 4096 Nov  9 07:24 analytics-alarm/
drwxr-xr-x  2 root root 4096 Oct 21 11:36 analytics-api/
drwxr-xr-x  2 root root 4096 Oct 21 11:21 analytics-collector/
drwxr-xr-x  2 root root 4096 Oct 21 11:41 analytics-query/
drwxr-xr-x  2 root root 4096 Oct 21 11:05 analytics-snmp/
drwxr-xr-x  2 root root 4096 Oct 21 11:44 analytics-topology/
drwxr-xr-x  2 root root 4096 Nov  9 11:27 cassandra/
drwxr-xr-x  2 root root 4096 Nov  9 07:39 config/
drwxr-xr-x  2 root root 4096 Nov  5 03:12 config-api/
drwxr-xr-x  2 root root 4096 Oct 21 08:07 config-device-manager/
drwxr-xr-x  2 root root 4096 Oct 21 07:38 config-discovery/
drwxr-xr-x  2 root root 4096 Oct 21 11:56 config-schema/
drwxr-xr-x  2 root root 4096 Oct 21 11:12 config-svc-monitor/
drwxr-xr-x  2 root root 4096 Nov  9 07:39 control/
drwxr-xr-x  2 root root 4096 Oct 21 12:16 control-control/
drwxr-xr-x  2 root root 4096 Oct 21 12:53 control-dns/
drwxr-xr-x  2 root root 4096 Oct 21 12:32 control-named/
drwxr-xr-x  2 root root 4096 Nov  9 10:14 ifmap/
drwxr-xr-x  3 root root 4096 Nov  9 10:57 keystone/
drwxr-xr-x  3 root root 4096 Nov  9 10:50 memcached/
drwxr-xr-x  2 root root 4096 Nov  9 06:04 neutron-server/
drwxr-xr-x  2 root root 4096 Nov  9 07:41 nova/
drwxr-xr-x  3 root root 4096 Nov  9 02:45 nova-api/
drwxr-xr-x  3 root root 4096 Nov  9 02:45 nova-cert/
drwxr-xr-x  3 root root 4096 Nov  9 11:33 nova-compute/
drwxr-xr-x  3 root root 4096 Nov  9 02:45 nova-conductor/
drwxr-xr-x  3 root root 4096 Nov  9 02:45 nova-consoleauth/
drwxr-xr-x  3 root root 4096 Nov  9 02:45 nova-novncproxy/
drwxr-xr-x  3 root root 4096 Nov  9 02:45 nova-scheduler/
drwxr-xr-x  4 root root 4096 Nov  9 10:51 rabbitmq/
drwxr-xr-x  2 root root 4096 Nov  9 10:48 redis/
drwxr-xr-x  3 root root 4096 Nov  9 12:29 vrouter-agent/
drwxr-xr-x  2 root root 4096 Nov  9 07:40 webui/
drwxr-xr-x  2 root root 4096 Oct 22 08:50 webui-job/
drwxr-xr-x  2 root root 4096 Oct 22 08:50 webui-server/
drwxr-xr-x  4 root root 4096 Nov  9 10:27 zookeeper/
```

If possible container images are reused as much as possible.  
E.g. the analytics image installs the software and anlytics-api,  
-collector, -query, -snmp and -topology apply the process  
relevant configurations and start the processs:

```
root:~/Dockerfiles/contrail# cat analytics/Dockerfile
FROM ubuntu:14.04
ENV DEBIAN_FRONTEND noninteractive
RUN echo "deb http://10.87.64.23/contrail-3.0-2668/ amd64/" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y --force-yes contrail-utils python-contrail contrail-lib \
     contrail-analytics

CMD ["/bin/sh"]
```

```
root:~/Dockerfiles/contrail# cat analytics-api/Dockerfile
FROM analytics
ENV DEBIAN_FRONTEND noninteractive

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/python","/usr/bin/contrail-analytics-api","-c","/etc/contrail/contrail-analytics-api.conf"]
LABEL net.juniper.contrail=analytics
LABEL net.juniper.node=controller
```

The base container must be built before the subcontainers can follow.
Containers are built using the docker build command from within the   
container directories. In this example a private repository is used  
for easy distribution of container images:

```
root@5b3s18:~/Dockerfiles/contrail/libvirt# docker build -t localhost:5100/libvirt:contrail-3.0-2668 .
Sending build context to Docker daemon 6.656 kB
Step 1 : FROM muccg/openstackbase:kilo
# Executing 2 build triggers...
Step 1 : RUN netstat -nr | grep '^0\.0\.0\.0' | awk '{print $2}' > ${BUILD_HOST_FILE}
 ---> Using cache
Step 1 : RUN echo "HEAD /" | nc -q -1 -n -v  `cat ${BUILD_HOST_FILE}` 3128 | grep squid-deb-proxy   && (echo "Acquire::http::Proxy \"http://$(cat ${BUILD_HOST_FILE}):3128\";" > ${APT_PROXY_CONF})   && (echo "Acquire::http::Proxy::ppa.launchpad.net DIRECT;" >> ${APT_PROXY_CONF})   || echo "No squid-deb-proxy detected on docker host"
 ---> Using cache
 ---> 58ff651fabe2
Step 2 : MAINTAINER https://github.com/muccg/
 ---> Using cache
 ---> 2255b1b673b6
Step 3 : RUN apt-get -qqy update && apt-get install -y --no-install-recommends   libvirt-bin   libvirt0   python-libvirt   qemu-kvm   && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
 ---> Using cache
 ---> a4fd5036bf67
Step 4 : COPY openstack-config /
 ---> Using cache
 ---> 2d30ba40c12c
Step 5 : COPY entrypoint.sh /
 ---> Using cache
 ---> 04778cadaa00
Step 6 : ENTRYPOINT /entrypoint.sh
 ---> Using cache
 ---> bd561d19da58
Step 7 : RUN echo "listen_tls = 0" >> /etc/libvirt/libvirtd.conf; echo 'listen_tcp = 1' >> /etc/libvirt/libvirtd.conf; echo 'tls_port = "16514"' >> /etc/libvirt/libvirtd.conf; echo 'tcp_port = "16509"' >> /etc/libvirt/libvirtd.conf; echo 'auth_tcp = "none"' >> /etc/libvirt/libvirtd.conf
 ---> Using cache
 ---> 81e07ef8ff39
Step 8 : RUN mkdir -p /var/lib/libvirt/images/
 ---> Using cache
 ---> 2401a1aef446
Step 9 : VOLUME /sys/fs/cgroup
 ---> Using cache
 ---> c03e538bebb0
Step 10 : RUN echo 'clear_emulator_capabilities = 0' >> /etc/libvirt/qemu.conf; echo 'user = "root"' >> /etc/libvirt/qemu.conf; echo 'group = "root"' >> /etc/libvirt/qemu.conf; echo 'cgroup_device_acl = [' >> /etc/libvirt/qemu.conf; echo '        "/dev/null", "/dev/full", "/dev/zero",'>> /etc/libvirt/qemu.conf; echo '        "/dev/random", "/dev/urandom",'>> /etc/libvirt/qemu.conf; echo '        "/dev/ptmx", "/dev/kvm", "/dev/kqemu",'>> /etc/libvirt/qemu.conf; echo '        "/dev/rtc", "/dev/hpet", "/dev/net/tun",'>> /etc/libvirt/qemu.conf; echo ']'>> /etc/libvirt/qemu.conf
 ---> Using cache
 ---> c768906652ec
Step 11 : LABEL net.juniper.openstack nova
 ---> Running in 437c931b43e0
 ---> e90a9b9d3604
Removing intermediate container 437c931b43e0
Step 12 : LABEL net.juniper.node compute
 ---> Running in 230abe9b41a7
 ---> 09da81eeb38b
Removing intermediate container 230abe9b41a7
Step 13 : CMD /usr/sbin/libvirtd -l
 ---> Running in 3371ac7acee0
 ---> 67b4febce1c7
Removing intermediate container 3371ac7acee0
Successfully built 67b4febce1c7
```

```
