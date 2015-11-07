#!/bin/bash

if [ -n "$HOST_IP" ]; then
    ./openstack-config --set /etc/nova/nova.conf DEFAULT my_ip $HOST_IP
fi
if [ -n "$VNC_PROXY" ]; then
    ./openstack-config --set /etc/nova/nova.conf DEFAULT vncserver_listen $VNC_PROXY
    ./openstack-config --set /etc/nova/nova.conf DEFAULT vncserver_proxyclient_address $VNC_PROXY
fi
if [ -n "$NEUTRON_SERVER" ]; then
    ./openstack-config --set /etc/nova/nova.conf neutron admin_auth_url http://$KEYSTONE_SERVER:35357/v2.0
    ./openstack-config --set /etc/nova/nova.conf neutron extension_sync_interval 600
    ./openstack-config --set /etc/nova/nova.conf neutron admin_username neutron
    ./openstack-config --set /etc/nova/nova.conf neutron admin_tenant_name service
    ./openstack-config --set /etc/nova/nova.conf neutron admin_password $ADMIN_PASSWORD
    ./openstack-config --set /etc/nova/nova.conf neutron url_timeout 30
    ./openstack-config --set /etc/nova/nova.conf neutron default_tenant_id $ADMIN_TENANT
    ./openstack-config --set /etc/nova/nova.conf neutron url http://$NEUTRON_SERVER:9696
    ./openstack-config --set /etc/nova/nova.conf neutron service_metadata_proxy True
    
fi
if [ -n "$KEYSTONE_SERVER" ]; then
    ./openstack-config --set /etc/nova/nova.conf DEFAULT auth_strategy keystone
    ./openstack-config --set /etc/nova/nova.conf DEFAULT network_api_class nova_contrail_vif.contrailvif.ContrailNetworkAPI
    ./openstack-config --del /etc/nova/nova.conf keystone_authtoken identity_uri
    ./openstack-config --del /etc/nova/nova.conf keystone_authtoken admin_tenant_name
    ./openstack-config --del /etc/nova/nova.conf keystone_authtoken admin_user
    ./openstack-config --del /etc/nova/nova.conf keystone_authtoken admin_password
    ./openstack-config --del /etc/nova/nova.conf keystone_authtoken revocation_cache_time
    ./openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_uri http://$KEYSTONE_SERVER:5000
    ./openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_url http://$KEYSTONE_SERVER:35357
    ./openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_plugin password
    ./openstack-config --set /etc/nova/nova.conf keystone_authtoken project_domain_id default
    ./openstack-config --set /etc/nova/nova.conf keystone_authtoken user_domain_id default
    ./openstack-config --set /etc/nova/nova.conf keystone_authtoken project_name service
    ./openstack-config --set /etc/nova/nova.conf keystone_authtoken username nova
    ./openstack-config --set /etc/nova/nova.conf keystone_authtoken password $ADMIN_PASSWORD
fi
if [ -n "$RABBIT_SERVER" ]; then
    ./openstack-config --set /etc/nova/nova.conf DEFAULT rpc_backend rabbit
    ./openstack-config --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_host $RABBIT_SERVER
    ./openstack-config --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_password guest
fi
if [ -n "$HOST_IP" ]; then
    ./openstack-config --set /etc/nova/nova.conf DEFAULT my_ip $HOST_IP
fi
if [ -n "$MYSQL_SERVER" ]; then
    ./openstack-config --set /etc/nova/nova.conf database connection mysql://nova:$ADMIN_PASSWORD@$MYSQL_SERVER/nova
fi
if [ -n "$GLANCE_SERVER" ]; then
    ./openstack-config --set /etc/nova/nova.conf glance host $GLANCE_SERVER
fi
./openstack-config --set /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp
./openstack-config --set /etc/nova/nova-compute.conf DEFAULT compute_driver libvirt.LibvirtDriver
./openstack-config --set /etc/nova/nova-compute.conf DEFAULT libvirt_vif_driver nova_contrail_vif.contrailvif.VRouterVIFDriver
./openstack-config --set /etc/nova/nova-compute.conf DEFAULT network_api_class nova_contrail_vif.contrailvif.ContrailNetworkAPI
./openstack-config --set /etc/nova/nova-compute.conf libvirt virt_type kvm
./openstack-config --set /etc/nova/nova-compute.conf libvirt connection_uri qemu+tcp://$HOST_IP/system
./openstack-config --set /etc/nova/nova-compute.conf libvirt live_migration_uri qemu+tcp://$HOST_IP/system

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
cp /lib/modules/3.19.0-25-generic/updates/dkms/vrouter.ko /

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
        #modprobe $kmod
        insmod /vrouter.ko
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
