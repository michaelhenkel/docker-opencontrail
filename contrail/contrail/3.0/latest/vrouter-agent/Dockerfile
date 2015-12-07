FROM ubuntu:14.04.3
MAINTAINER mhenkel
ENV DEBIAN_FRONTEND noninteractive
RUN echo "deb http://10.87.64.23/contrail/3.0/latest/ amd64/" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y --force-yes linux-headers-`uname -r` \
     python-iniparse \
     contrail-utils \
     python-contrail \
     contrail-lib \
     contrail-vrouter-agent \
     contrail-vrouter-dkms \
     contrail-vrouter-utils \
     contrail-vrouter-init

LABEL net.juniper.contrail=vrouter
LABEL net.juniper.node=compute
RUN mkdir /rhel-vrouter
COPY rhel-vrouter/vrouter.ko /rhel-vrouter/vrouter.ko
COPY entrypoint.sh /
COPY openstack-config /
COPY vrouter-functions.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-vrouter-agent"]
