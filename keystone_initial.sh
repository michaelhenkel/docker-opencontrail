export LC_ALL=C
MYSQL_SERVER=host1
KEYSTONE_SERVER=host1
GLANCE_SERVER=host1
CINDER_SERVER=host1
NEUTRON_SERVER=host1
NOVA_SERVER=host1
ADMIN_USER=admin
ADMIN_PASSWORD=contrail123

####### keystone

openstack service create   --name keystone --description "OpenStack Identity" identity
openstack endpoint create \
  --publicurl http://$KEYSTONE_SERVER:5000/v2.0 \
  --internalurl http://$KEYSTONE_SERVER:5000/v2.0 \
  --adminurl http://$KEYSTONE_SERVER:35357/v2.0 \
  --region RegionOne \
  identity
openstack project create --description "Admin Project" $ADMIN_USER
openstack user create --password $ADMIN_PASSWORD  $ADMIN_USER
openstack role create $ADMIN_USER
openstack role add --project $ADMIN_USER --user $ADMIN_USER $ADMIN_USER
openstack project create --description "Service Project" service

######## glance

mysql -u root -h $MYSQL_SERVER -p$ADMIN_PASSWORD -e 'CREATE DATABASE glance;'
mysql -u root -h $MYSQL_SERVER -p$ADMIN_PASSWORD -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' \
  IDENTIFIED BY '$ADMIN_PASSWORD';
  GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' \
  IDENTIFIED BY '$ADMIN_PASSWORD';"

openstack user create --password $ADMIN_PASSWORD glance
openstack role add --project service --user glance admin
openstack service create --name glance \
  --description "OpenStack Image Service" image
openstack endpoint create \
  --publicurl http://$GLANCE_SERVER:9292 \
  --internalurl http://$GLANCE_SERVER:9292 \
  --adminurl http://$GLANCE_SERVER:9292 \
  --region RegionOne \
  image

######## cinder

mysql -u root -h $MYSQL_SERVER -p$ADMIN_PASSWORD -e 'CREATE DATABASE cinder;'
mysql -u root -h $MYSQL_SERVER -p$ADMIN_PASSWORD -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' \
  IDENTIFIED BY '$ADMIN_PASSWORD';
  GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' \
  IDENTIFIED BY '$ADMIN_PASSWORD';"

openstack user create --password $ADMIN_PASSWORD cinder
openstack role add --project service --user cinder admin
openstack service create --name cinder \
  --description "OpenStack Block Storage" volume
openstack service create --name cinderv2 \
  --description "OpenStack Block Storage" volumev2
openstack endpoint create \
  --publicurl http://$CINDER_SERVER:8776/v2/%\(tenant_id\)s \
  --internalurl http://$CINDER_SERVER:8776/v2/%\(tenant_id\)s \
  --adminurl http://$CINDER_SERVER:8776/v2/%\(tenant_id\)s \
  --region RegionOne \
  volume

openstack endpoint create \
  --publicurl http://$CINDER_SERVER:8776/v2/%\(tenant_id\)s \
  --internalurl http://$CINDER_SERVER:8776/v2/%\(tenant_id\)s \
  --adminurl http://$CINDER_SERVER:8776/v2/%\(tenant_id\)s \
  --region RegionOne \
  volumev2
######## neutron

openstack user create --password $ADMIN_PASSWORD neutron
openstack role add --project service --user neutron admin
openstack service create --name neutron \
  --description "OpenStack Networking" network
openstack endpoint create \
  --publicurl http://$NEUTRON_SERVER:9696 \
  --adminurl http://$NEUTRON_SERVER:9696 \
  --internalurl http://$NEUTRON_SERVER:9696 \
  --region RegionOne \
  network

######## nova

mysql -u root -h $MYSQL_SERVER -p$ADMIN_PASSWORD -e 'CREATE DATABASE nova;'
mysql -u root -h $MYSQL_SERVER -p$ADMIN_PASSWORD -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' \
  IDENTIFIED BY '$ADMIN_PASSWORD';
  GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' \
  IDENTIFIED BY '$ADMIN_PASSWORD';"

openstack user create --password $ADMIN_PASSWORD nova
openstack role add --project service --user nova admin
openstack service create --name nova \
  --description "OpenStack Compute" compute
openstack endpoint create \
  --publicurl http://$NOVA_SERVER:8774/v2/%\(tenant_id\)s \
  --internalurl http://$NOVA_SERVER:8774/v2/%\(tenant_id\)s \
  --adminurl http://$NOVA_SERVER:8774/v2/%\(tenant_id\)s \
  --region RegionOne \
  compute

#su -s /bin/sh -c "nova-manage db sync" nova

