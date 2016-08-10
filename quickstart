# Quick Start (change INTERFACE, EXT_RANGE and GW)

Controller Node:    

```
apt-get install -y zookeeper zookeeperd git
#change zookeeper port to 2191 in /etc/zookeeper/conf/zoo.conf (sed -i 's/2181/2191/g' /etc/zookeeper/conf/zoo.conf)
service zookeeper restart
curl -sSL https://experimental.docker.com/ | sh
curl -L https://github.com/docker/compose/releases/download/1.7.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
INTERFACE=l3vm
EXT_RANGE=192.168.1.200/28
IP=`ifconfig $INTERFACE | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
SUBNET=`ip r sh |grep "$INTERFACE  proto" |grep -v default |awk '{print $1}'`
GW=192.168.1.1
echo DOCKER_OPTS=\"--cluster-store=zk://$IP:2191 --cluster-advertise=$INTERFACE:2376\" >> /etc/default/docker
service docker restart
docker network create -d overlay internal
docker network create -d macvlan --subnet $SUBNET --ip-range $EXT_RANGE --gateway $GW -o parent=$INTERFACE ext
git clone https://github.com/michaelhenkel/docker-opencontrail
cd docker-opencontrail/compose/contrail
docker-compose -f contrail-database.yml up -d
docker-compose -f keystone.yml up -d
docker-compose -f contrail-config.yml up -d
docker-compose -f contrail-analytics.yml up -d
docker-compose -f contrail-control.yml up -d
### optional for OpenStack
docker-compose -f glance.yml up -d
docker-compose -f nova.yml up -d
docker-compose -f neutron.yml up -d
for i in `ls *.yml`; do docker-compose -f $i ps; done
```

Compute Node:    

```
apt-get install -y git
git clone https://github.com/michaelhenkel/docker-opencontrail
curl -sSL https://experimental.docker.com/ | sh
curl -L https://github.com/docker/compose/releases/download/1.7.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
## $IP = Controller IP
echo DOCKER_OPTS=\"--cluster-store=zk://$IP:2191 --cluster-advertise=$INTERFACE:2376\" >> /etc/default/docker
cd docker-opencontrail/compose/compute
#adjust common.env
docker-compose up -d
```
