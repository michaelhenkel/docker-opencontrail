FROM michaelhenkel/cinder:liberty
MAINTAINER https://hub.docker.com/r/michaelhenkel

RUN apt-get -qqy update && apt-get install -y --no-install-recommends \
  cinder-api \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
LABEL net.juniper.openstack=cinder
LABEL net.juniper.node=controller

CMD ["/usr/bin/python","/usr/bin/cinder-api"]

