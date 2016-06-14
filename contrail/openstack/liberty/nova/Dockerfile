FROM michaelhenkel/openstackbase:liberty
MAINTAINER https://hub.docker.com/r/michaelhenkel
RUN sed -i "s/archive.ubuntu.com/us.archive.ubuntu.com/g" /etc/apt/sources.list

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
  python-pip \
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
  nova-api \
  nova-conductor \
  nova-consoleauth \
  nova-scheduler \
  nova-cert \
  nova-novncproxy \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6839FE77
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys D4865D83
RUN echo "deb http://ppa.launchpad.net/mhenkel-3/opencontrail/ubuntu trusty main" >> /etc/apt/sources.list
RUN echo "deb http://ppa.launchpad.net/opencontrail/ppa/ubuntu trusty main" >> /etc/apt/sources.list
RUN apt-get -qqy update && apt-get install -y --force-yes --no-install-recommends \
  python-contrail \
  contrail-lib \
  contrail-nova-driver \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip install python-openstackclient

COPY openstack-config /
#COPY entrypoint.sh /

RUN sed -i 's/return cls(skip_policy_check=skip_policy_check)/return cls()/g' /usr/lib/python2.7/dist-packages/nova/network/__init__.py
RUN sed -i 's/from nova.openstack.common import log as logging/from oslo_log import log as logging/g' /usr/lib/python2.7/dist-packages/nova_contrail_vif/contrailvif.py
RUN sed -i 's/from nova.openstack.common import processutils/from oslo_concurrency import processutils/g' /usr/lib/python2.7/dist-packages/nova_contrail_vif/contrailvif.py

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/bin/sh"]

