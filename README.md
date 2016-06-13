# docker-opencontrail

This guide explains how Docker containers can be used as a portable and Linux OS agnostic  
OpenStack/OpenContrail deployment system.  
The goal is to run a single process per container without needing an init system  
inside the container. This works for all processes besides Kafka/Zookeeper  
which run both inside the same container using supervisord as the init system.

# Components  
  OpenStack and OpenContrail require a number of components which can be grouped together:

  - Common
    - Keystone
    - RabbitMQ
    - Redis
    - Memcached  
    - Cassandra
    - Zookeeper/Kafka

  - OpenStack
    - Nova  
      - api
      - cert
      - compute
      - conductor
      - consoleauth
      - scheduler
      - novncproxy
    - Neutron-server
    - Cinder
      - api
      - scheduler
    - Glance
      - registry
      - api
    - Libvirt

  - OpenContrail
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

# Architecture    
```
+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+    
|                                                                                                                                                                                                                    |    
|                                                                                                                                                                            +-------------+                         |    
|                                                                                                                                                                            |             |                         |    
|                                                                                                                                                                            | +-----+     |                         |    
|                                                                                     +---------------+                                                                      | |redis|     |                         |    
|                                                                                     |               |                                                                      | +-----+     |                         |    
|                                                                                     | +---+         |                                                                      | +---+       |                         |    
|                                                                                     | |api|         |                                                 +------------------+ | |api|       |                         |    
|                                                                                     | +---+         |                                                 |                  | | +---+       |                         |    
|                                                                                     | +----+        |                                                 | +---+            | | +---------+ |                         |    
|                                                                                     | |cert|        |                                                 | |api|            | | |collector| |                         |    
|                                                                                     | +----+        |                                                 | +---+            | | +---------+ |                         |    
|                                                                                     | +--------+    |                                                 | +-----------+    | | +-----+     |                         |    
|                                                                                     | |schedule|    |                                                 | |svc|monitor|    | | |alarm|     |                         |    
|                                                                                     | +--------+    |                                                 | +-----------+    | | +-----+     |                         |    
|                                                                                     | +---------+   |                                                 | +--------------+ | | +-----+     |                         |    
|                                                                                     | |conductor|   | +-------------+ +------------+                  | |device|manager| | | |query|     | +-------------+         |    
|                                                                                     | +---------+   | |             | |            |                  | +--------------+ | | +-----+     | |             |         |    
|                                                                                     | +----------+  | | +---+       | | +---+      |                  | +------+         | | +----+      | | +-------+   |         |    
|                                                                                     | |novncproxy|  | | |api|       | | |api|      |                  | |schema|         | | |snmp|      | | |control|   |         |    
|                                                                                     | +----------+  | | +---+       | | +---+      |                  | +------+         | | +----+      | | +-------+   |         |    
|                                                                                     | +-----------+ | | +---------+ | | +--------+ |                  | +---------+      | | +--------+  | | +---------+ |         |    
|                                                                                     | |consoleauth| | | |scheduler| | | |registry| |                  | |discovery|      | | |topology|  | | |named/dns| |         |    
|                                                                                     | +-----------+ | | +---------+ | | +--------+ |                  | +---------+      | | +--------+  | | +---------+ |         |    
|                                                                                     |               | |             | |            |                  |                  | |             | |             |         |    
|  +---------------+ +-----+ +--------+ +--------+ +---------+ +---------+ +--------+ |   nova        | |   cinder    | |   glance   | +--------------+ |  config          | |  analytics  | |  control    | +-----+ |    
|  |zookeeper/kafka| |redis| |rabbitmq| |keystone| |memcached| |cassandra| | mariadb| |               | |             | |            | |neutron|server| |                  | |             | |             | |webui| |    
|  +---------------+ +-----+ +--------+ +--------+ +---------+ +---------+ +--------+ +---------------+ +-------------+ +------------+ +--------------+ +------------------+ +-------------+ +-------------+ +-----+ |    
|           |           |        |          |           |          |           |             |                 |              |               |                  |              |   |            |   |          |    |    
|           |           |        |          |           |          |           |             |                 |              |               |                  |           +-----------------------------+    |    |    
|           |           |        |          |           |          |           |             |                 |              |               |                  |           |  extNw MACVLAN 10.0.0.128/28|    |    |    
|           |           |        |          |           |          |           |             |                 |              |               |                  |           +-----------------------------+    |    |    
|           |           |        |          |           |          |           |             |                 |              |               |                  |              |         |      |              |    |    
| +----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+ |    
| |                                                                                             intNw Overlay 172.16.0.0/16                                                                                        | |    
| +----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+ |    
|                                                                                                 |                                                                                       |                          |    
|                                                                                          +----------------------------------------------------------------------------------------------+                          |    
|                                                                                          | eth0 10.0.0.1 |                                                                                                         |    
+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+    
```

Containers of a group (nova, cinder, glance, config, analytics, control)    
share the same networking namespace meaning that all containers of that group will    
use the same IP address but processes remain separated.

The Containers (groups) connect to an overlay network provided by libnetworks    
overlay driver. The overlay driver allows for multi-host networking as well    
takes care for name resolution.    

The analytics and control group additionally connect to an external network    
provided by libnetworks MacVlan driver. This network provides un-proxied and     
un-NAT'd access to the physical network. This is needed to maintain connectivity    
to a datacenter router as well as to compute nodes.    
Commuincation between the Containers uses the overlay network.    


This label filter shows all OpenContrail relevant container images:  
```
root# docker images --filter label=net.juniper.contrail |grep 3.0.1-e24cc66
REPOSITORY                            TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
michaelhenkel/control-control         3.0.1-e24cc66       8751fc5e0496        6 hours ago         614.4 MB
michaelhenkel/analytics-collector     3.0.1-e24cc66       7d776f7b27d8        6 hours ago         511.5 MB
michaelhenkel/control-named           3.0.1-e24cc66       121fc23d0dd6        6 hours ago         614.4 MB
michaelhenkel/config-api              3.0.1-e24cc66       2d5aa8c138f2        8 hours ago         621.4 MB
michaelhenkel/analytics-query         3.0.1-e24cc66       24424eae1c07        23 hours ago        511.5 MB
michaelhenkel/analytics-alarm         3.0.1-e24cc66       58e80761ea3a        23 hours ago        511.5 MB
michaelhenkel/analytics-api           3.0.1-e24cc66       360e9567a48f        23 hours ago        511.5 MB
michaelhenkel/nodemgr-config          3.0.1-e24cc66       6e2453b024d7        44 hours ago        406.5 MB
michaelhenkel/webui-server            3.0.1-e24cc66       94743b119f9a        45 hours ago        482.7 MB
michaelhenkel/config-svc-monitor      3.0.1-e24cc66       86216e7ef884        2 days ago          621.4 MB
michaelhenkel/config-schema           3.0.1-e24cc66       2c8226c4ced8        2 days ago          621.4 MB
michaelhenkel/config-discovery        3.0.1-e24cc66       5f045dc6a873        2 days ago          621.4 MB
michaelhenkel/config-device-manager   3.0.1-e24cc66       620ec25c956a        2 days ago          621.4 MB
michaelhenkel/webui-job               3.0.1-e24cc66       8da6f13944c0        2 days ago          462.4 MB
michaelhenkel/analytics-topology      3.0.1-e24cc66       cfc6ddbbb29f        2 days ago          511.5 MB
michaelhenkel/analytics-snmp          3.0.1-e24cc66       4a0b46c8cb8a        2 days ago          511.5 MB
michaelhenkel/control-dns             3.0.1-e24cc66       86db74bd88cc        2 days ago          614.4 MB
michaelhenkel/vrouter-agent           3.0.1-e24cc66       a244e9f78dcc        2 days ago          753.7 MB
michaelhenkel/ifmap                   3.0.1-e24cc66       3a65935a5e1e        2 days ago          326.5 MB
```
 
OpenStack container:
```
root# docker images |grep liberty
REPOSITORY                                     TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
michaelhenkel/nova-api                         liberty             e61cd1c9f924        45 hours ago        628.4 MB
michaelhenkel/nova                             liberty             a31960013104        2 days ago          628.4 MB
michaelhenkel/neutron-server                   liberty             3285fb893fe8        2 days ago          432.6 MB
michaelhenkel/nova-compute                     liberty             c4161730d426        3 days ago          842.8 MB
michaelhenkel/nova-consoleauth                 liberty             6c9d46253e51        7 days ago          607 MB
michaelhenkel/nova-cert                        liberty             322b99b7a4cb        7 days ago          607 MB
michaelhenkel/nova-novncproxy                  liberty             37183ba1adc6        7 days ago          607 MB
michaelhenkel/nova-scheduler                   liberty             f8ca541bdf45        7 days ago          607 MB
michaelhenkel/nova-conductor                   liberty             716da4fabb34        7 days ago          607 MB
michaelhenkel/glance-api                       liberty             8c236ad4e978        7 days ago          430 MB
michaelhenkel/horizon                          liberty             2f382a3a867c        7 days ago          429.9 MB
michaelhenkel/neutron                          liberty             35e7d9b2d87c        2 weeks ago         388.7 MB
michaelhenkel/keystone                         liberty             3a670971aa5d        4 weeks ago         404.3 MB
michaelhenkel/glance-registry                  liberty             d79357d56721        4 weeks ago         430 MB
michaelhenkel/glance                           liberty             39317b4c811c        4 weeks ago         430 MB
michaelhenkel/openstackbase                    liberty             6a89adffb008        6 months ago        206.5 MB
```

Common containers:
```
REPOSITORY                                     TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
michaelhenkel/libvirt                          1.0                 bcf09b971ef3        8 days ago          283.8 MB
michaelhenkel/cassandra                        1.0                 a011641b77de        8 days ago          367.6 MB
michaelhenkel/zookeeper                        1.0                 09bcd722b314        3 weeks ago         422.1 MB
michaelhenkel/rabbitmq                         1.0                 ddd8b5b9188d        6 months ago        182.9 MB
michaelhenkel/mariadb                          1.0                 c845cde9a255        6 months ago        263.2 MB
michaelhenkel/memcached                        1.0                 2e41f8be1486        6 months ago        132.2 MB
michaelhenkel/redis                            1.0                 9c6dbdbceb09        6 months ago        109.2 MB
```

# Container image build process

Containers required to run OpenContrail or containing OpenContrail libraries are located  
in the contrail directory:  

```
root:~/docker-opencontrail/contrail/contrail/3.0.1/e24cc66# ll
total 104
drwxr-xr-x 26 root root 4096 Jun  2 17:56 ./
drwxr-xr-x  4 root root 4096 Jun  2 17:56 ../
drwxr-xr-x  2 root root 4096 Jun  2 00:17 analytics/
drwxr-xr-x  2 root root 4096 Jun  2 01:36 analytics-alarm/
drwxr-xr-x  2 root root 4096 Jun  2 01:35 analytics-api/
drwxr-xr-x  3 root root 4096 Jun  2 19:08 analytics-collector/
drwxr-xr-x  2 root root 4096 Jun  2 01:38 analytics-query/
drwxr-xr-x  2 root root 4096 Jun  2 01:38 analytics-snmp/
drwxr-xr-x  2 root root 4096 Jun  2 01:39 analytics-topology/
drwxr-xr-x  2 root root 4096 May 31 19:41 config/
drwxr-xr-x  3 root root 4096 Jun  2 23:13 config-api/
drwxr-xr-x  2 root root 4096 May 31 19:41 config-device-manager/
drwxr-xr-x  2 root root 4096 May 31 19:41 config-discovery/
drwxr-xr-x  2 root root 4096 May 31 19:41 config-schema/
drwxr-xr-x  2 root root 4096 May 31 19:41 config-svc-monitor/
drwxr-xr-x  2 root root 4096 May 31 19:41 control/
drwxr-xr-x  2 root root 4096 Jun  2 22:38 control-control/
drwxr-xr-x  2 root root 4096 May 31 19:41 control-dns/
drwxr-xr-x  3 root root 4096 Jun  2 18:29 control-named/
drwxr-xr-x  2 root root 4096 May 31 19:41 ifmap/
drwxr-xr-x  2 root root 4096 Jun  1 04:39 nodemgr/
drwxr-xr-x  3 root root 4096 Jun  1 04:48 nodemgr-config/
drwxr-xr-x  3 root root 4096 Jun  2 03:16 vrouter-agent/
drwxr-xr-x  2 root root 4096 May 31 19:41 webui/
drwxr-xr-x  2 root root 4096 May 31 19:41 webui-job/
drwxr-xr-x  3 root root 4096 Jun  1 23:05 webui-server/
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
root:~/docker-opencontrail/contrail/contrail/3.0.1/e24cc66# cat analytics/Dockerfile
FROM ubuntu:14.04.3
ENV DEBIAN_FRONTEND noninteractive
RUN sed -i "s/archive.ubuntu.com/us.archive.ubuntu.com/g" /etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6839FE77
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys D4865D83
RUN echo "deb http://ppa.launchpad.net/mhenkel-3/opencontrail/ubuntu trusty main" >> /etc/apt/sources.list
RUN echo "deb http://ppa.launchpad.net/opencontrail/ppa/ubuntu trusty main" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y --force-yes contrail-utils python-contrail contrail-lib \
     contrail-analytics python-iniparse
COPY openstack-config /

CMD ["/bin/sh"]
```

```
root:~/docker-opencontrail/contrail/contrail/3.0.1/e24cc66# cat analytics-api/Dockerfile
FROM michaelhenkel/analytics:3.0.1-e24cc66
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

This list also includes container images not needed for OpenContrail (mariadb, horizon, cinder, glance).

# Quick Start

apt-get install -y zookeeper zookeeperd
service zookeeper start
curl -sSL https://experimental.docker.com/ | sh
curl -L https://github.com/docker/compose/releases/download/1.7.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
INTERFACE=l3vm
EXT_RANGE=192.168.1.200/28
IP=`ifconfig $INTERFACE | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
SUBNET=`ip r sh |grep "$INTERFACE  proto" |grep -v default |awk '{print $1}'`
GW=192.168.1.1
echo DOCKER_OPTS=\"--cluster-store=zk://$IP:2181 --cluster-advertise=$INTERFACE:2376\" >> /etc/default/docker
service docker restart
docker network create -d overlay internal
docker network create -d macvlan --subnet $SUBNET --ip-range $EXT_RANGE --gateway $GW -o parent=$INTERFACE ext
cd docker-opencontrail/compose/contrail
docker-compose up -d
docker-compose -f contrail-config.yml up -d
docker-compose -f contrail-analytics.yml up -d
docker-compose -f contrail-control.yml up -d
for i in `ls *.yml`; do docker-compose -f $i ps; done
