FROM michaelhenkel/openstackbase:liberty
MAINTAINER https://hub.docker.com/r/michaelhenkel

RUN apt-get -qqy update && apt-get install -y --no-install-recommends \
  mysql-client \
  keystone \
  python-keystoneclient \
  python-memcache \
  python-mysqldb \
  python-iniparse \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY openstack-config /
COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
LABEL net.juniper.contrail=common
LABEL net.juniper.openstack=common
LABEL net.juniper.node=controller
CMD ["/usr/bin/python","/usr/bin/keystone-all"]
