FROM michaelhenkel/openstackbase:liberty
MAINTAINER https://hub.docker.com/r/michaelhenkel

RUN apt-get -qqy update && apt-get install -y --no-install-recommends \
  mysql-client \
  glance \
  python-glanceclient \
  python-iniparse \
  python-memcache \
  python-mysqldb \
  python-ceph \
  python-pip \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip install python-openstackclient
COPY openstack-config /
LABEL net.juniper.openstack=glance
LABEL net.juniper.node=controller

CMD ["/bin/sh"]
