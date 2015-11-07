#docker run -it --privileged --net host \
docker run -d --net host \
  --env NODE_TYPE=contrail-vrouter \
  --env ANALYTICS_SERVER=192.168.0.1 \
  --env DISCOVERY_SERVER=192.168.0.1 \
  --env CONTRAIL_DNS_SERVER=192.168.0.1 \
  --env HOST_IP=192.168.0.12 \
  --env CIDR=24 \
  --env GATEWAY_IP=192.168.0.1 \
  --env PHYSICAL_INTERFACE=eth0 \
  --env ADMIN_TENANT=admin \
  --env ADMIN_TOKEN=contrail123 \
  --env ADMIN_PASSWORD=contrail123 \
  --name nodemgr-vrouter1 nodemgr-vrouter
#  --name vrouter-agent1 vrouter-agent /bin/bash
