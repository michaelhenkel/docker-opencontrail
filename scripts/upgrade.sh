#!/bin/bash

version=`curl -silent http://10.84.5.120/github-build/mainline/LATEST/ubuntu-14-04/kilo/ |grep contrail-install-packages_mainline | awk -F"contrail-install-packages_mainline" '{print $2}' |awk -F"-" '{print $2}'`

function updateRepo {
  mkdir -p /var/www/html/contrail/3.0/$version/amd64
  rm /var/www/html/contrail/3.0/latest
  ln -s /var/www/html/contrail/3.0/$version /var/www/html/contrail/3.0/latest
  cd /var/www/html/contrail/3.0/latest/amd64
  wget http://10.84.5.120/github-build/mainline/LATEST/ubuntu-14-04/kilo/contrail-install-packages_mainline-$version-kilo.tgz
  tar zxvf contrail-install-packages_mainline-$version-kilo.tgz
  cd /var/www/html/contrail/3.0/$version
  dpkg-scanpackages amd64 | gzip -9c > amd64/Packages.gz
}

function buildContainer {
  cd /root/Dockerfiles/scripts
  ./build.py -t contrail -b structure.yaml
  ./build.py -t contrail -s structure.yaml
  ./build.py -t openstack -x nova structure.yaml
  ./build.py -t openstack -c neutron-server structure.yaml
  ./build.py -t openstack -c nova-compute structure.yaml
}

function startContainer {
  for service in `ls ~/Dockerfiles/compose/contrail/3.0/latest`; do
    cd ~/Dockerfiles/compose/contrail/3.0/latest/$service
    docker-compose stop && docker-compose rm -f && docker-compose up -d
  done
  for service in nova neutron; do
    cd ~/Dockerfiles/compose/openstack/liberty/$service
    docker-compose stop && docker-compose rm -f && docker-compose up -d
  done
}

updateRepo
buildContainer
startContainer
