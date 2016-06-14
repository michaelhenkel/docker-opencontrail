#!/bin/bash

if [ -n "$CONTROL_SERVER" ]; then
    ./openstack-config --set /etc/contrail/contrail-vrouter-agent.conf CONTROL-NODE server $CONTROL_SERVER
fi
if [ -n "$ANALYTICS_SERVER" ]; then
    ./openstack-config --set /etc/contrail/contrail-vrouter-agent.conf DEFAULT collectors $ANALYTICS_SERVER:8086
fi
if [ -n "$DISCOVERY_SERVER" ]; then
    ./openstack-config --set /etc/contrail/contrail-vrouter-agent.conf DISCOVERY server $DISCOVERY_SERVER 
fi
if [ -n "$CONTRAIL_DNS_SERVER" ]; then
    ./openstack-config --set /etc/contrail/contrail-vrouter-agent.conf DNS server $CONTRAIL_DNS_SERVER
fi
./openstack-config --set /etc/contrail/contrail-vrouter-agent.conf NETWORKS control_network_ip $HOST_IP
./openstack-config --set /etc/contrail/contrail-vrouter-agent.conf VIRTUAL-HOST-INTERFACE name vhost0
./openstack-config --set /etc/contrail/contrail-vrouter-agent.conf VIRTUAL-HOST-INTERFACE ip $HOST_IP/$CIDR
./openstack-config --set /etc/contrail/contrail-vrouter-agent.conf VIRTUAL-HOST-INTERFACE gateway $GATEWAY_IP
./openstack-config --set /etc/contrail/contrail-vrouter-agent.conf VIRTUAL-HOST-INTERFACE physical_interface $PHYSICAL_INTERFACE
./openstack-config --set /etc/contrail/contrail-vrouter-agent.conf VIRTUAL-HOST-INTERFACE compute_node_address $HOST_IP

if [ -n "$CREATE_MODULE" ]; then
  cd /usr/src/modules/contrail-vrouter
  tar zxvf contrail-vrouter-3.0.tar.gz
  grep "Red Hat Enterprise Linux Server release 7.1" /etc/redhat-release
  if [ $? -eq 0 ]; then
      cd /usr/bin
      rm gcc g++ cpp
      ln -s gcc-4.9 gcc
      ln -s g++-4.9 g++
      ln -s cpp-4.9 cpp
      cd /usr/src/modules/contrail-vrouter
      make
      mkdir -p /lib/modules/`uname -r`/extra/net/vrouter
      cp -r /usr/src/modules/contrail-vrouter/vrouter.ko /lib/modules/`uname -r`/extra/net/vrouter
      depmod -a
      lsmod |grep vrouter 
      if [ $? -eq 0 ]; then
        rmmod vrouter
      fi
      #modprobe vrouter
  else
      lsb_release -a |grep Ubuntu
      if [ $? -eq 0 ]; then
          cd /usr/src/modules/contrail-vrouter
          make
          mkdir -p /lib/modules/`uname -r`/extra/net/vrouter
          cp -r /usr/src/modules/contrail-vrouter/vrouter.ko /lib/modules/`uname -r`/extra/net/vrouter
          depmod -a
          lsmod |grep vrouter
          if [ $? -eq 0 ]; then
            rmmod vrouter
          fi
          #modprobe vrouter
     fi
  fi
fi

cat << EOF > /etc/contrail/agent_param
LOG=/var/log/contrail.log
CONFIG=/etc/contrail/agent.conf
prog=/usr/bin/contrail-vrouter-agent
kmod=vrouter
pname=contrail-vrouter-agent
LIBDIR=/usr/lib64
VHOST_CFG=/etc/network/interfaces
DEVICE=vhost0
dev=$PHYSICAL_INTERFACE
vgw_subnet_ip=
vgw_int=
LOGFILE=--log-file=/var/log/contrail/vrouter.log
EOF
#cp /lib/modules/3.19.0-25-generic/updates/dkms/vrouter.ko /

source /etc/contrail/agent_param

function pkt_setup () {
    for f in /sys/class/net/$1/queues/rx-*
    do
        q="$(echo $f | cut -d '-' -f2)"
        r=$(($q%32))
        s=$(($q/32))
        ((mask=1<<$r))
        str=(`printf "%x" $mask`)
        if [ $s -gt 0 ]; then
            for ((i=0; i < $s; i++))
            do
                str+=,00000000
            done
        fi
        echo $str > $f/rps_cpus
    done
    ifconfig $1 up
}

function insert_vrouter() {
    if cat $CONFIG | grep '^\s*platform\s*=\s*dpdk\b' &>/dev/null; then
        vrouter_dpdk_start
        return $?
    fi

    grep $kmod /proc/modules 1>/dev/null 2>&1
    if [ $? != 0 ]; then
        modprobe $kmod
        #insmod /vrouter.ko
        if [ $? != 0 ]
        then
            echo "$(date) : Error inserting vrouter module"
            return 1
        fi

        if [ -f /sys/class/net/pkt1/queues/rx-0/rps_cpus ]; then
            pkt_setup pkt1
        fi
        if [ -f /sys/class/net/pkt2/queues/rx-0/rps_cpus ]; then
            pkt_setup pkt2
        fi
        if [ -f /sys/class/net/pkt3/queues/rx-0/rps_cpus ]; then
            pkt_setup pkt3
        fi
    fi

    # check if vhost0 is not present, then create vhost0 and $dev
    if [ ! -L /sys/class/net/vhost0 ]; then
        echo "$(date): Creating vhost interface: $DEVICE."
        # for bonding interfaces
        loops=0
        while [ ! -f /sys/class/net/$dev/address ]
        do
            sleep 1
            loops=$(($loops + 1))
            if [ $loops -ge 60 ]; then
                echo "Unable to look at /sys/class/net/$dev/address"
                return 1
            fi
        done

        DEV_MAC=$(cat /sys/class/net/$dev/address)
        vif --create $DEVICE --mac $DEV_MAC
        if [ $? != 0 ]; then
            echo "$(date): Error creating interface: $DEVICE"
        fi


        echo "$(date): Adding $dev to vrouter"
        DEV_MAC=$(cat /sys/class/net/$dev/address)
        vif --add $dev --mac $DEV_MAC --vrf 0 --vhost-phys --type physical
        if [ $? != 0 ]; then
            echo "$(date): Error adding $dev to vrouter"
        fi

        vif --add $DEVICE --mac $DEV_MAC --vrf 0 --type vhost --xconnect $dev
        if [ $? != 0 ]; then
            echo "$(date): Error adding $DEVICE to vrouter"
        fi
    fi
    return 0
}
insert_vrouter
ip address delete $HOST_IP/$CIDR dev $PHYSICAL_INTERFACE
ip address add $HOST_IP/$CIDR dev vhost0
ip link set dev vhost0 up
ip route add default via $GATEWAY_IP

exec "$@"
