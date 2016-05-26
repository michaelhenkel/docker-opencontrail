FROM michaelhenkel/nova:liberty
MAINTAINER https://hub.docker.com/r/michaelhenkel

#RUN apt-get -qqy update && apt-get install -y --force-yes --no-install-recommends \
#  nova-api \
#  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN pip install python-openstackclient
COPY entrypoint.sh /

CMD ["/usr/bin/python","/usr/bin/nova-api"]

LABEL net.juniper.openstack=nova
LABEL net.juniper.node=controller
