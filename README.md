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

The initial container setup is defined in the Dockerfile.  
Settings in that file apply to all containers using that image.
Per container runtime configuration is specified in the  
entrypoint.sh script.
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
root:~/Dockerfiles/contrail/libvirt# docker build -t \
> localhost:5100/libvirt:contrail-3.0-2668 .
Sending build context to Docker daemon 6.656 kB
Step 1 : FROM ubuntu:14.04
 ---> 0a17decee413
Step 2 : MAINTAINER https://github.com/muccg/
 ---> Using cache
 ---> 14617fcf3369
Step 3 : RUN apt-get -qqy update && apt-get install -y --no-install-recommends   libvirt-bin   libvirt0   python-libvirt   qemu-kvm   && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
 ---> Running in 165aa3053496
^Croot@5b3s18:~/Dockerfiles/contrail/libvirtvi Dockerfile
root@5b3s18:~/Dockerfiles/contrail/libvirt# docker build -t localhost:5100/libvirt:contrail-3.0-2668 .
Sending build context to Docker daemon 6.656 kB
Step 1 : FROM ubuntu:14.04
 ---> 0a17decee413
Step 2 : MAINTAINER mhenkel@juniper.net
 ---> Using cache
 ---> 7af08a0a4f18
Step 3 : RUN apt-get -qqy update && apt-get install -y --no-install-recommends   libvirt-bin   libvirt0   python-libvirt   qemu-kvm   && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
 ---> Running in 00084c4c07ef
Reading package lists...
Building dependency tree...
Reading state information...
The following extra packages will be installed:
  acl augeas-lenses bridge-utils cgroup-lite dbus dnsmasq-base gettext-base
.
.
.
Removing intermediate container cc610ea1696f
Step 11 : LABEL net.juniper.openstack nova
 ---> Running in c39c929a4487
 ---> e86d3138ecd2
Removing intermediate container c39c929a4487
Step 12 : LABEL net.juniper.node compute
 ---> Running in a089d9ba313b
 ---> 4b350c3d57f6
Removing intermediate container a089d9ba313b
Step 13 : CMD /usr/sbin/libvirtd -l
 ---> Running in 746e25d6c66b
 ---> 0828e2df0f6f
Removing intermediate container 746e25d6c66b
Successfully built 0828e2df0f6f
```

In order to streamline the build process a build script can be used.  
It uses a yaml file as an input paramater and builds base-, sub- or individual  
containers:
```
root:~/Dockerfiles/scripts# ./build.py -h
usage: build.py [-h] [-b] [-s] [-c CONTAINER] file

positional arguments:
  file                  yaml file containing the container structure

optional arguments:
  -h, --help            show this help message and exit
  -b, --base            switch to build all base images
  -s, --sub             switch to build all sub images
  -c CONTAINER, --container CONTAINER
                        specifies a container as listed in file

```

After all container images are built docker ps will list them:

```
root:~/Dockerfiles/scripts# docker images |grep contrail-3.0-2668
localhost:5100/mariadb                 contrail-3.0-2668    e682d6bde08d        34 seconds ago       263.2 MB
localhost:5100/horizon                 contrail-3.0-2668    2e74ec87bc28        About a minute ago   365 MB
localhost:5100/cinder-scheduler        contrail-3.0-2668    03d7946222a1        About a minute ago   376.4 MB
localhost:5100/cinder-api              contrail-3.0-2668    bbdf849de33e        2 minutes ago        376.4 MB
localhost:5100/cinder                  contrail-3.0-2668    d9f27a0f0912        2 minutes ago        301.1 MB
localhost:5100/glance-registry         contrail-3.0-2668    eeadabbf812c        4 minutes ago        393.1 MB
localhost:5100/glance-api              contrail-3.0-2668    32a432000d46        5 minutes ago        393.1 MB
localhost:5100/glance                  contrail-3.0-2668    c07a19b2dbc8        6 minutes ago        300.4 MB
localhost:5100/libvirt                 contrail-3.0-2668    0828e2df0f6f        2 hours ago          284.2 MB
localhost:5100/vrouter-agent           contrail-3.0-2668    ed7662557493        15 hours ago         566.8 MB
localhost:5100/cassandra               contrail-3.0-2668    06e371fb7560        16 hours ago         364.1 MB
localhost:5100/keystone                contrail-3.0-2668    767c649a62ab        16 hours ago         372.5 MB
localhost:5100/memcached               contrail-3.0-2668    b7b4bc32b7bd        16 hours ago         132.2 MB
localhost:5100/rabbitmq                contrail-3.0-2668    95db8b5bfaea        16 hours ago         182.9 MB
localhost:5100/redis                   contrail-3.0-2668    e1aba142d899        16 hours ago         109.2 MB
localhost:5100/zookeeper               contrail-3.0-2668    31f8451c0729        16 hours ago         421.6 MB
localhost:5100/ifmap                   contrail-3.0-2668    6634c685b73d        17 hours ago         328.6 MB
localhost:5100/nova                    contrail-3.0-2668    7d6b9c1b38c3        19 hours ago         563.2 MB
localhost:5100/config                  contrail-3.0-2668    b3ce9d84d840        19 hours ago         471.7 MB
localhost:5100/webui                   contrail-3.0-2668    046d976b7a07        19 hours ago         469 MB
localhost:5100/analytics               contrail-3.0-2668    1e29143192d4        19 hours ago         444.7 MB
localhost:5100/control                 contrail-3.0-2668    14df9cb441ed        19 hours ago         573.5 MB
localhost:5100/config-svc-monitor      contrail-3.0-2668    cca0a05e2eec        19 hours ago         471.3 MB
localhost:5100/config-schema           contrail-3.0-2668    f632849389dd        19 hours ago         471.3 MB
localhost:5100/config-discovery        contrail-3.0-2668    9066abc22b50        19 hours ago         471.3 MB
localhost:5100/config-device-manager   contrail-3.0-2668    8c8f62de6016        19 hours ago         471.3 MB
localhost:5100/config-api              contrail-3.0-2668    827228f8eac7        19 hours ago         471.3 MB
localhost:5100/webui-server            contrail-3.0-2668    54e9fba13435        19 hours ago         458.9 MB
localhost:5100/webui-job               contrail-3.0-2668    853c2a421474        19 hours ago         458.9 MB
localhost:5100/analytics-topology      contrail-3.0-2668    6daffa7a9a0f        19 hours ago         444.5 MB
localhost:5100/analytics-snmp          contrail-3.0-2668    bdc060fffb94        19 hours ago         444.5 MB
localhost:5100/analytics-query         contrail-3.0-2668    d5dd077f890d        19 hours ago         444.5 MB
localhost:5100/analytics-collector     contrail-3.0-2668    97977ae0218d        19 hours ago         444.5 MB
localhost:5100/analytics-api           contrail-3.0-2668    6c8e23a01263        19 hours ago         444.5 MB
localhost:5100/analytics-alarm         contrail-3.0-2668    6eba0d2fad7a        19 hours ago         444.5 MB
localhost:5100/nova-scheduler          contrail-3.0-2668    803a6e3fe803        19 hours ago         562.9 MB
localhost:5100/nova-novncproxy         contrail-3.0-2668    78e7244749ad        19 hours ago         562.9 MB
localhost:5100/nova-consoleauth        contrail-3.0-2668    3ea7536356c2        19 hours ago         562.9 MB
localhost:5100/nova-conductor          contrail-3.0-2668    389fa7181601        19 hours ago         562.9 MB
localhost:5100/nova-compute            contrail-3.0-2668    406ffc1cea92        19 hours ago         812.8 MB
localhost:5100/nova-cert               contrail-3.0-2668    9685ee342968        19 hours ago         562.9 MB
localhost:5100/nova-api                contrail-3.0-2668    abda305f0612        19 hours ago         562.9 MB
localhost:5100/control-named           contrail-3.0-2668    58c66578c4ef        19 hours ago         573 MB
localhost:5100/control-dns             contrail-3.0-2668    7131c438cd35        19 hours ago         573 MB
localhost:5100/control-control         contrail-3.0-2668    09be1889a7e1        19 hours ago         573 MB
localhost:5100/neutron-server          contrail-3.0-2668    becd59c6add2        20 hours ago         377.6 MB
```

This list also includes container images not needed for OpenContrail (mariadb, horizon, cinder, glance).

# Runtime configuration and start of a container/service

Each container uses an entrypoint.sh shell script which  
configures the container application at the time the 
container is started. This works by passing environment  
variables to the docker command which will be evaluated  
by the script. The following script creates a nova.conf  
file. As all nova services use the same nova.conf file  
the entrypoint script is injected into the base nova image.  
If a per subcontainer configuration is needed the  
entrypoint.sh script will be injected into the subcontainer.
Variables like $HOST_IP, $KEYSTONE_SERVER etc. must be  
passed to the docker run command.

```
root:~/Dockerfiles/contrail/nova# cat entrypoint.sh
#!/bin/bash

if [ -n "$HOST_IP" ]; then
    echo "my_ip = $HOST_IP" >> /etc/nova/nova.conf
fi
if [ -n "$VNC_PROXY" ]; then
    echo "vncserver_listen = $VNC_PROXY" >> /etc/nova/nova.conf
    echo "vncserver_proxyclient_address = $VNC_PROXY" >> /etc/nova/nova.conf
fi
if [ -n "$KEYSTONE_SERVER" ]; then
    echo "auth_strategy = keystone" >> /etc/nova/nova.conf
fi
if [ -n "$RABBIT_SERVER" ]; then
    echo "rpc_backend = rabbit" >> /etc/nova/nova.conf
fi
if [ -n "$HOST_IP" ]; then
    echo "my_ip = $HOST_IP" >> /etc/nova/nova.conf
fi
if [ -n "$KEYSTONE_SERVER" ]; then
    echo "[keystone_authtoken]" >> /etc/nova/nova.conf
    echo "auth_uri = http://$KEYSTONE_SERVER:5000" >> /etc/nova/nova.conf
    echo "auth_url = http://$KEYSTONE_SERVER:35357" >> /etc/nova/nova.conf
    echo "auth_plugin = password" >> /etc/nova/nova.conf
    echo "project_domain_id = default" >> /etc/nova/nova.conf
    echo "user_domain_id = default" >> /etc/nova/nova.conf
    echo "project_name = service" >> /etc/nova/nova.conf
    echo "username = nova" >> /etc/nova/nova.conf
    echo "password = $ADMIN_PASSWORD" >> /etc/nova/nova.conf
fi
if [ -n "$RABBIT_SERVER" ]; then
    echo "[oslo_messaging_rabbit]" >> /etc/nova/nova.conf
    echo "rabbit_host = $RABBIT_SERVER" >> /etc/nova/nova.conf
    echo "rabbit_password = guest" >> /etc/nova/nova.conf
fi
if [ -n "$MYSQL_SERVER" ]; then
    echo "[database]" >> /etc/nova/nova.conf
    echo "connection = mysql://nova:$ADMIN_PASSWORD@$MYSQL_SERVER/nova" >> /etc/nova/nova.conf
fi
if [ -n "$GLANCE_SERVER" ]; then
    echo "[glance]" >> /etc/nova/nova.conf
    echo "host = $GLANCE_SERVER" >> /etc/nova/nova.conf
fi
echo "[oslo_concurrency]" >> /etc/nova/nova.conf
echo "lock_path = /var/lib/nova/tmp" >> /etc/nova/nova.conf

exec "$@"
```

Containers can be started individually using the docker run command.  
With the amount of containers needed this can become quite painful.  
Docker offers a tool called docker-compose which helps to define  
services. A service consists of several containers. Following  
the container structure from above these are the defined services:

```
root:~/Dockerfiles/compose# ll
total 60
drwxr-xr-x 15 root root 4096 Nov 10 03:36 ./
drwxr-xr-x 12 root root 4096 Nov 10 03:26 ../
drwxr-xr-x  2 root root 4096 Nov  9 11:12 analytics/
drwxr-xr-x  2 root root 4096 Nov 10 03:36 cinder/
drwxr-xr-x  2 root root 4096 Nov  9 10:58 common/
drwxr-xr-x  2 root root 4096 Nov  9 11:10 config/
drwxr-xr-x  2 root root 4096 Nov  9 11:15 control/
drwxr-xr-x  2 root root 4096 Nov  9 11:05 database/
drwxr-xr-x  2 root root 4096 Nov 10 03:35 glance/
drwxr-xr-x  2 root root 4096 Nov 10 03:37 horizon/
drwxr-xr-x  2 root root 4096 Nov 10 03:39 mariadb/
drwxr-xr-x  2 root root 4096 Nov  9 12:39 neutron/
drwxr-xr-x  2 root root 4096 Nov  9 12:37 nova/
drwxr-xr-x  2 root root 4096 Nov  9 12:33 nova-compute/
drwxr-xr-x  2 root root 4096 Nov  9 11:16 webui/
```

The service is defined in a docker-compose.yml file in  
each directory:

```
root@5b3s18:~/Dockerfiles/compose# cat nova/docker-compose.yml
nova-api:
  cap_add:
    - NET_ADMIN
  image: localhost:5100/nova-api:contrail-3.0-2668
  net: host
  env_file: ./common.env
nova-cert:
  image: localhost:5100/nova-cert:contrail-3.0-2668
  net: host
  env_file: ./common.env
nova-compute:
  image: localhost:5100/nova-compute:contrail-3.0-2668
  net: host
  env_file: ./common.env
nova-conductor:
  image: localhost:5100/nova-conductor:contrail-3.0-2668
  net: host
  env_file: ./common.env
nova-consoleauth:
  image: localhost:5100/nova-consoleauth:contrail-3.0-2668
  net: host
  env_file: ./common.env
nova-novncproxy:
  image: localhost:5100/nova-novncproxy:contrail-3.0-2668
  net: host
  env_file: ./common.env
nova-scheduler:
  image: localhost:5100/nova-scheduler:contrail-3.0-2668
  net: host
  env_file: ./common.env
```

The common.env file contains the environment variables  
passed to the entrypoint.sh script for the runtime  
configuration of the container.  
An interesting service is the nova-compute one:  

```
root@5b3s18:~/Dockerfiles/compose# cat nova-compute/docker-compose.yml
libvirt:
  image: 192.168.0.1:5100/libvirt
  privileged: true
  volumes:
    - /var/lib/nova/instances:/var/lib/nova/instances
    - /lib/modules:/lib/modules
    - /var/lib/libvirt/:/var/lib/libvirt
    - /sys/fs/cgroup:/sys/fs/cgroup:rw
  net: host
  env_file: ./common.env
vrouter:
  image: 192.168.0.1:5100/vrouter-agent:contrail-3.0-2668
  privileged: true
  net: host
  env_file: ./common.env
  volumes:
    - /etc/redhat-release:/etc/redhat-release
    - /lib/modules:/lib/modules
nova-compute:
  image: 192.168.0.1:5100/nova-compute:contrail-3.0-2668
  privileged: true
  volumes:
    - /var/lib/nova/instances:/var/lib/nova/instances
  net: host
  env_file: ./common.env
```

In order to make the instances persistent they must be  
stored outside the container. Therefore the libvirt  
and nova-compute containers mount the /var/lib/nova/instances  
path on the host. Virtual machines are stored there  
and will still be there after the containers are destroyed.  
Mariadb, cassandra and zookeeper also mount host paths  
to make the databases persistent. The paths on the host  
must exist BEFORE the containers are started.
Another special case is the privileged mode for the compute  
service. As the containers must access kernel modules  
(kvm, vrouter) they must be privileged.  
  
A service is started with the docker-compose up -d  
and stopped with the docker-compose stop command from  
within the service directory. All service containers  
can be removed using the docker-compose rm -f command:

```
root:~/Dockerfiles/compose/glance# docker-compose up -d
Creating glance_glance-api_1
Creating glance_glance-registry_1
```

The docker-compose logs command aggregates all  
output from the processes:

```
root:~/Dockerfiles/compose/glance# docker-compose logs
Attaching to glance_glance-registry_1, glance_glance-api_1
glance-registry_1 | Traceback (most recent call last):
glance-api_1      | 2015-11-10 11:51:45.880 1 WARNING oslo_config.cfg [-] Option "username" from group "keystone_authtoken" is deprecated. Use option "username" from group "keystone_authtoken".
glance-registry_1 | 2015-11-10 11:51:46.078 1 WARNING oslo_config.cfg [-] Option "username" from group "keystone_authtoken" is deprecated. Use option "username" from group "keystone_authtoken".
```

# Building a compute node (RHEL 7.1)
In order to build a compute node the following steps are  
required:

1. update repo
   ```
   yum -y update
   ```

2. install docker
```
curl -sSL https://get.docker.com/ | sh
```

3. install docker-compse
```
curl -L https://github.com/docker/compose/releases/download/1.5.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

4. point docker daemon to private repo
```
sed -i 's_^ExecStart.* .*_& --insecure-registry 192.168.0.1:5100_' /lib/systemd/system/docker.service
```
where 192.168.0.1 is the host running the repository

5. start the docker daemon
```
systemctl daemon-reload
systemctl restart docker
```

5. pull container images
```
docker pull 192.168.0.1:5100/vrouter-agent:contrail-3.0-2668
docker pull 192.168.0.1:5100/libvirt:contrail-3.0-2668
docker pull 192.168.0.1:5100/nova-compute:contrail-3.0-2668
6. create service
```
mkdir compute

cd compute

cat << EOF > common.env
ADMIN_PASSWORD=contrail123
ADMIN_TENANT=admin
ADMIN_TOKEN=contrail123
ADMIN_USER=admin
ANALYTICS_API_SERVER=192.168.0.1
ANALYTICS_SERVER=192.168.0.1
ANALYTICS_SERVER=192.168.0.1
CASSANDRA_SERVER=192.168.0.1
CIDR=24
CINDER_SERVER=192.168.0.1
COLLECTOR_SERVER=192.168.0.14
CONFIG_API_SERVER=192.168.0.1
CONTRAIL_DNS_SERVER=192.168.0.1
CONTROL_SERVER=192.168.0.1
DISCOVERY_SERVER=192.168.0.1
DISCOVERY_SERVER=192.168.0.1
GATEWAY_IP=192.168.0.1
GLANCE_SERVER=192.168.0.1
HOST_IP=192.168.0.14
IFMAP_SERVER=192.168.0.1
KEYSTONE_SERVER=192.168.0.1
MEMCACHED_SERVER=192.168.0.1
MYSQL_SERVER=192.168.0.1
NEUTRON_SERVER=192.168.0.1
NOVA_SERVER=192.168.0.1
PHYSICAL_INTERFACE=eth0
RABBIT_SERVER=192.168.0.1
REDIS_SERVER=192.168.0.1
VNC_PROXY=192.168.0.14
WEBUI_JOB_SERVER=192.168.0.1
ZOOKEEPER_SERVER=192.168.0.1
EOF

cat << EOF > docker-compose.yml
libvirt:
  image: 192.168.0.1:5100/libvirt:contrail-3.0-2668
  privileged: true
  volumes:
    - /var/lib/nova/instances:/var/lib/nova/instances
    - /lib/modules:/lib/modules
    - /var/lib/libvirt/:/var/lib/libvirt
    - /sys/fs/cgroup:/sys/fs/cgroup:rw
  net: host
  env_file: ./common.env
vrouter:
  image: 192.168.0.1:5100/vrouter-agent:contrail-3.0-2668
  privileged: true
  net: host
  env_file: ./common.env
  volumes:
    - /etc/redhat-release:/etc/redhat-release
    - /lib/modules:/lib/modules
nova-compute:
  image: 192.168.0.1:5100/nova-compute:contrail-3.0-2668
  privileged: true
  volumes:
    - /var/lib/nova/instances:/var/lib/nova/instances
  net: host
  env_file: ./common.env
EOF
```

7. start service
```
docker-compose up -d
```

8. check service
```
[root@compute-rhel2 compute]# docker exec -it compute_vrouter_1 vif --list
Vrouter Interface Table

Flags: P=Policy, X=Cross Connect, S=Service Chain, Mr=Receive Mirror
       Mt=Transmit Mirror, Tc=Transmit Checksum Offload, L3=Layer 3, L2=Layer 2
       D=DHCP, Vp=Vhost Physical, Pr=Promiscuous, Vnt=Native Vlan Tagged
       Mnp=No MAC Proxy, Dpdk=DPDK PMD Interface, Rfl=Receive Filtering Offload, Mon=Interface is Monitored
       Uuf=Unknown Unicast Flood, Vof=VLAN insert/strip offload

vif0/0      OS: eth0
            Type:Physical HWaddr:52:54:00:55:bb:f9 IPaddr:0
            Vrf:0 Flags:TcL3L2Vp MTU:1514 Ref:3
            RX packets:311  bytes:23394 errors:0
            TX packets:230  bytes:26146 errors:0

vif0/1      OS: vhost0
            Type:Host HWaddr:52:54:00:55:bb:f9 IPaddr:c0a8000d
            Vrf:0 Flags:L3L2 MTU:1514 Ref:3
            RX packets:226  bytes:25978 errors:0
            TX packets:311  bytes:23394 errors:0

vif0/2      OS: pkt0
            Type:Agent HWaddr:00:00:5e:00:01:00 IPaddr:0
            Vrf:65535 Flags:L3 MTU:1514 Ref:2
            RX packets:4  bytes:328 errors:0
            TX packets:187  bytes:22586 errors:0

vif0/4350   OS: pkt3
            Type:Stats HWaddr:00:00:00:00:00:00 IPaddr:0
            Vrf:65535 Flags:L3L2 MTU:9136 Ref:1
            RX packets:0  bytes:0 errors:0
            TX packets:0  bytes:0 errors:0

vif0/4351   OS: pkt1
            Type:Stats HWaddr:00:00:00:00:00:00 IPaddr:0
            Vrf:65535 Flags:L3L2 MTU:9136 Ref:1
            RX packets:0  bytes:0 errors:0
            TX packets:0  bytes:0 errors:0



[root@compute-rhel2 compute]# docker logs -f compute_nova-compute_1
.
.
.
2015-11-10 13:35:19.461 1 INFO nova.scheduler.client.report [req-406f2973-5905-41ae-aec2-625b68a0d789 - - - - -] Compute_service record updated for ('compute-rhel2.localdomain', 'compute-rhel2.localdomain')
2015-11-10 13:35:19.462 1 INFO nova.compute.resource_tracker [req-406f2973-5905-41ae-aec2-625b68a0d789 - - - - -] Compute_service record updated for compute-rhel2.localdomain:compute-rhel2.localdomain
2015-11-10 13:35:19.489 1 INFO oslo_messaging._drivers.impl_rabbit [req-406f2973-5905-41ae-aec2-625b68a0d789 - - - - -] Connecting to AMQP server on 192.168.0.1:5672
2015-11-10 13:35:19.503 1 INFO oslo_messaging._drivers.impl_rabbit [req-406f2973-5905-41ae-aec2-625b68a0d789 - - - - -] Connected to AMQP server on 192.168.0.1:5672
```

on the controller:

```
root@5b3s18:~# nova host-list
+-----------------------------------+-------------+----------+
| host_name                         | service     | zone     |
+-----------------------------------+-------------+----------+
| 5b3s18                            | cert        | internal |
| 5b3s18                            | conductor   | internal |
| 5b3s18                            | consoleauth | internal |
| 5b3s18                            | scheduler   | internal |
| compute1                          | compute     | compute1 |
| compute2                          | compute     | compute2 |
| compute-docker1                   | compute     | docker1  |
| localhost.localdomain.localdomain | compute     | nova     |
| compute-rhel1.localdomain         | compute     | rhel1    |
| compute-rhel2.localdomain         | compute     | nova     |
+-----------------------------------+-------------+----------+
root@5b3s18:~# nova aggregate-create rhel2 rhel2
+----+-------+-------------------+-------+---------------------------+
| Id | Name  | Availability Zone | Hosts | Metadata                  |
+----+-------+-------------------+-------+---------------------------+
| 5  | rhel2 | rhel2             |       | 'availability_zone=rhel2' |
+----+-------+-------------------+-------+---------------------------+
root@5b3s18:~# nova aggregate-add-host rhel2 compute-rhel2.localdomain
Host compute-rhel2.localdomain has been successfully added for aggregate 5
+----+-------+-------------------+-----------------------------+---------------------------+
| Id | Name  | Availability Zone | Hosts                       | Metadata                  |
+----+-------+-------------------+-----------------------------+---------------------------+
| 5  | rhel2 | rhel2             | 'compute-rhel2.localdomain' | 'availability_zone=rhel2' |
+----+-------+-------------------+-----------------------------+---------------------------+
root@5b3s18:~# nova boot --image cirros --flavor nano --nic net-id=4c089997-8698-4933-8301-20ce05e90d91 --availability-zone rhel2 x8
+--------------------------------------+-----------------------------------------------+
| Property                             | Value                                         |
+--------------------------------------+-----------------------------------------------+
| OS-DCF:diskConfig                    | MANUAL                                        |
| OS-EXT-AZ:availability_zone          | nova                                          |
| OS-EXT-SRV-ATTR:host                 | -                                             |
| OS-EXT-SRV-ATTR:hypervisor_hostname  | -                                             |
| OS-EXT-SRV-ATTR:instance_name        | instance-0000004b                             |
| OS-EXT-STS:power_state               | 0                                             |
| OS-EXT-STS:task_state                | scheduling                                    |
| OS-EXT-STS:vm_state                  | building                                      |
| OS-SRV-USG:launched_at               | -                                             |
| OS-SRV-USG:terminated_at             | -                                             |
| accessIPv4                           |                                               |
| accessIPv6                           |                                               |
| adminPass                            | 47o2zq7VmzN7                                  |
| config_drive                         |                                               |
| created                              | 2015-11-10T13:42:39Z                          |
| flavor                               | nano (04d0b07d-3842-4321-b018-c9217fb83786)   |
| hostId                               |                                               |
| id                                   | 900cfbca-5243-48ab-8a80-c86709ecbafb          |
| image                                | cirros (10cd8a05-17b9-492e-982a-044034b234e7) |
| key_name                             | -                                             |
| metadata                             | {}                                            |
| name                                 | x8                                            |
| os-extended-volumes:volumes_attached | []                                            |
| progress                             | 0                                             |
| security_groups                      | default                                       |
| status                               | BUILD                                         |
| tenant_id                            | aad6f936af2b4ba1aea50489c50e54a9              |
| updated                              | 2015-11-10T13:42:40Z                          |
| user_id                              | 570754d102644f7996a9a4e5c6cd066d              |
+--------------------------------------+-----------------------------------------------+
root@5b3s18:~# nova list
+--------------------------------------+------+--------+------------+-------------+---------------+
| ID                                   | Name | Status | Task State | Power State | Networks      |
+--------------------------------------+------+--------+------------+-------------+---------------+
| c5c66e60-6c43-475f-8cad-12bc17c79d22 | c1   | ACTIVE | -          | Running     | test=1.1.1.3  |
| 1b2ff9c8-55dd-41b5-8677-aa4cd820b993 | c2   | ACTIVE | -          | Running     | test=1.1.1.4  |
| 304aabe7-b7a8-4242-9d80-2fbfde013a71 | i3   | ACTIVE | -          | Running     | test2=2.2.2.3 |
| 2d3bf494-b697-4948-849a-c329f4e295f5 | i4   | ACTIVE | -          | Running     | test2=2.2.2.4 |
| 64c013da-480b-4656-af84-0284d4e5ded6 | t4   | ACTIVE | -          | Running     | test=1.1.1.5  |
| 5c758cf1-6348-4c9b-be10-6dc935984a52 | x6   | ACTIVE | -          | Running     | test=1.1.1.6  |
| ae39dcbb-5a45-4a86-b048-6e6fa7826d94 | x7   | ACTIVE | -          | Running     | test=1.1.1.7  |
| 900cfbca-5243-48ab-8a80-c86709ecbafb | x8   | ACTIVE | -          | Running     | test=1.1.1.8  |
+--------------------------------------+------+--------+------------+-------------+---------------+
```

back on the compute node:

```
root@compute-rhel2 compute]# ip ro sh
default via 192.168.0.1 dev vhost0
169.254.0.3 dev vhost0  proto 109  scope link
172.17.0.0/16 dev docker0  proto kernel  scope link  src 172.17.0.1
192.168.0.0/24 dev vhost0  proto kernel  scope link  src 192.168.0.14
192.168.122.0/24 dev virbr0  proto kernel  scope link  src 192.168.122.1

[root@compute-rhel2 ~]# ssh cirros@169.254.0.3
The authenticity of host '169.254.0.3 (169.254.0.3)' can't be established.
RSA key fingerprint is 92:ef:31:a8:a5:66:46:02:e7:af:eb:48:d1:fe:47:f0.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '169.254.0.3' (RSA) to the list of known hosts.
cirros@169.254.0.3's password:
$ ping 1.1.1.7
PING 1.1.1.7 (1.1.1.7): 56 data bytes
64 bytes from 1.1.1.7: seq=0 ttl=64 time=7.537 ms
64 bytes from 1.1.1.7: seq=1 ttl=64 time=1.432 ms
```

on the other compute node:

```
[root@compute-rhel1 ~]# tcpdump -nS -i eth0 host 192.168.0.14
tcpdump: WARNING: eth0: no IPv4 address assigned
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
09:45:37.230884 IP 192.168.0.14.56219 > 192.168.0.13.4789: VXLAN, flags [I] (0x08), vni 4
IP 1.1.1.8 > 1.1.1.7: ICMP echo request, id 16641, seq 0, length 64
09:45:37.236403 IP 192.168.0.13.50887 > 192.168.0.14.4789: VXLAN, flags [I] (0x08), vni 4
IP 1.1.1.7 > 1.1.1.8: ICMP echo reply, id 16641, seq 0, length 64
09:45:38.229796 IP 192.168.0.14.56219 > 192.168.0.13.4789: VXLAN, flags [I] (0x08), vni 4
IP 1.1.1.8 > 1.1.1.7: ICMP echo request, id 16641, seq 1, length 64
09:45:38.230273 IP 192.168.0.13.50887 > 192.168.0.14.4789: VXLAN, flags [I] (0x08), vni 4
IP 1.1.1.7 > 1.1.1.8: ICMP echo reply, id 16641, seq 1, length 64
09:45:42.243921 IP 192.168.0.14.58833 > 192.168.0.13.4789: VXLAN, flags [I] (0x08), vni 4
```

