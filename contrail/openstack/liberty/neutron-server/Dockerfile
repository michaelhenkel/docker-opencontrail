FROM michaelhenkel/openstackbase:liberty
MAINTAINER https://hub.docker.com/r/michaelhenkel
RUN apt-get -qqy update && apt-get install -y --force-yes --no-install-recommends \
  patch \
  mysql-client \
  python-iniparse \
  python-memcache \
  python-mysqldb \
  neutron-server \
  python-neutronclient \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "deb http://10.87.64.23/contrail/3.0/latest amd64/" >> /etc/apt/sources.list
RUN apt-get -qqy update && apt-get install -y --force-yes --no-install-recommends \
  python-contrail \
  contrail-lib \
  neutron-plugin-contrail \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

LABEL net.juniper.openstack=neutron
LABEL net.juniper.node=controller
COPY openstack-config /
COPY entrypoint.sh /
COPY contrail.patch /
RUN cd /usr/lib/python2.7/dist-packages && cat /contrail.patch | patch -p1

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/python","/usr/bin/neutron-server"]

