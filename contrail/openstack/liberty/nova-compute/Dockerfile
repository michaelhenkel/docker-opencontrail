FROM michaelhenkel/openstackbase:liberty
MAINTAINER https://hub.docker.com/r/michaelhenkel
RUN apt-get -qqy update && apt-get install -y --no-install-recommends \
  mysql-client \
  python-iniparse \
  python-memcache \
  python-mysqldb \
  python-six \
  python-sqlalchemy \ 
  alembic \
  python-tz \
  python-pbr \
  python-oslo-config \
  python-netifaces \
  python-oslo.i18n \
  python-oslo-utils \
  python-oslosphinx \
  python-pycadf \
  python-amqp \
  python-cliff \
  python-oslo.serialization \
  python-oslo.utils \
  python-novaclient \
  python-testtools \
  python-fixtures \
  python-posix-ipc \
  python-retrying \
  python-oslo-concurrency \
  python-migrate \
  python-oslo-db \
  python-oslo.config \
  python-oslo-middleware \
  python-oslo-rootwrap \
  nova-compute \
  nova-compute-kvm \
  nova-compute-libvirt \
  python-netifaces \
  libguestfs-tools \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6839FE77
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys D4865D83
RUN echo "deb http://ppa.launchpad.net/mhenkel-3/opencontrail/ubuntu trusty main" >> /etc/apt/sources.list
RUN echo "deb http://10.87.64.33/contrail/ amd64/" >> /etc/apt/sources.list
RUN echo "deb http://ppa.launchpad.net/opencontrail/ppa/ubuntu trusty main" >> /etc/apt/sources.list
RUN apt-get -qqy update && apt-get install -y --force-yes --no-install-recommends \
  python-contrail \
  contrail-lib \
  contrail-nova-driver \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
LABEL net.juniper.openstack=nova
LABEL net.juniper.node=controler

COPY openstack-config /
COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/python","/usr/bin/nova-compute","--config-file=/etc/nova/nova.conf"]
LABEL net.juniper.openstack=nova
LABEL net.juniper.node=compute
