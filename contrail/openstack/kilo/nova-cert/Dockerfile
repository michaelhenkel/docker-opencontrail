FROM nova
MAINTAINER https://github.com/muccg/

#RUN apt-get -qqy update && apt-get install -y --no-install-recommends \
#  nova-cert \
#  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/usr/bin/python","/usr/bin/nova-cert"]

LABEL net.juniper.openstack=nova
LABEL net.juniper.node=controller
