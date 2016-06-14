FROM glance
MAINTAINER https://github.com/muccg/

RUN apt-get -qqy update && apt-get install -y --no-install-recommends \
  glance-registry \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
LABEL net.juniper.openstack=glance
LABEL net.juniper.node=controller

CMD ["/usr/bin/python","/usr/bin/glance-registry"]
