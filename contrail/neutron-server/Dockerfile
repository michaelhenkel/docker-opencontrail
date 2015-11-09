FROM muccg/openstackbase:kilo
MAINTAINER https://github.com/muccg/
RUN apt-get -qqy update && apt-get install -y --force-yes --no-install-recommends \
  mysql-client \
  python-iniparse \
  python-memcache \
  python-mysqldb \
  neutron-server \
  python-neutronclient \
#  python-contrail \
#  contrail-lib \
#  neutron-plugin-contrail \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "deb http://10.87.64.23/contrail-3.0-2668/ amd64/" >> /etc/apt/sources.list
RUN apt-get -qqy update && apt-get install -y --force-yes --no-install-recommends \
  python-contrail \
  contrail-lib \
  neutron-plugin-contrail \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

LABEL net.juniper.openstack=neutron
LABEL net.juniper.node=controller
COPY openstack-config /
COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/python","/usr/bin/neutron-server"]

