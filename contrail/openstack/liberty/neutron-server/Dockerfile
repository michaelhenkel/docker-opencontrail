FROM michaelhenkel/openstackbase:liberty
MAINTAINER https://hub.docker.com/r/michaelhenkel
RUN sed -i "s/archive.ubuntu.com/us.archive.ubuntu.com/g" /etc/apt/sources.list
RUN apt-get -qqy update && apt-get install -y --force-yes --no-install-recommends \
  patch \
  mysql-client \
  python-iniparse \
  python-memcache \
  python-mysqldb \
  neutron-server \
  python-neutronclient \
  python-pip \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "deb http://10.87.64.33/contrail/ amd64/" >> /etc/apt/sources.list
RUN apt-get -qqy update && apt-get install -y --force-yes --no-install-recommends \
  python-contrail \
  contrail-lib \
  neutron-plugin-contrail \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip install python-openstackclient

LABEL net.juniper.openstack=neutron
LABEL net.juniper.node=controller
COPY openstack-config /
COPY entrypoint.sh /
COPY contrail.patch /
#RUN cd /usr/lib/python2.7/dist-packages && cat /contrail.patch | patch -p1

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/python","/usr/bin/neutron-server","--config-file","/etc/neutron/neutron.conf","--config-file","/etc/neutron/plugins/opencontrail/ContrailPlugin.ini"]

