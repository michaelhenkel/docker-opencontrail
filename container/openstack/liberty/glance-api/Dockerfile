FROM michaelhenkel/glance:liberty
MAINTAINER https://hub.docker.com/r/michaelhenkel

RUN apt-get -qqy update && apt-get install -y --no-install-recommends \
  glance-api \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
LABEL net.juniper.openstack=glance
LABEL net.juniper.node=controller

CMD ["/usr/bin/python","/usr/bin/glance-api"]
