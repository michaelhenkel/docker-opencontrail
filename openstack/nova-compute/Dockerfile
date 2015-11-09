FROM muccg/openstackbase:kilo
MAINTAINER https://github.com/muccg/

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

RUN echo "deb http://10.87.64.23//contrail/ amd64/" >> /etc/apt/sources.list
RUN apt-get -qqy update && apt-get install -y --force-yes --no-install-recommends \
  python-contrail \
  contrail-lib \
  contrail-nova-driver \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY openstack-config /
COPY entrypoint.sh /

RUN sed -i 's/return cls(skip_policy_check=skip_policy_check)/return cls()/g' /usr/lib/python2.7/dist-packages/nova/network/__init__.py
RUN sed -i 's/from nova.openstack.common import log as logging/from oslo_log import log as logging/g' /usr/lib/python2.7/dist-packages/nova_contrail_vif/contrailvif.py
RUN sed -i 's/from nova.openstack.common import processutils/from oslo_concurrency import processutils/g' /usr/lib/python2.7/dist-packages/nova_contrail_vif/contrailvif.py
RUN sed -i 's/super(VRouterVIFDriver, self).__init__(get_connection)/super(VRouterVIFDriver, self).__init__()/g' /usr/lib/python2.7/dist-packages/nova_contrail_vif/contrailvif.py

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/python","/usr/bin/nova-compute","--config-file=/etc/nova/nova.conf","--config-file=/etc/nova/nova-compute.conf"]
