FROM ubuntu:14.04
ENV DEBIAN_FRONTEND noninteractive

RUN echo "deb http://10.87.64.23//contrail/ amd64/" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y linux-headers-3.19.0-25-generic
RUN apt-get install -y --force-yes contrail-utils python-contrail contrail-lib \
     contrail-vrouter-agent \
     contrail-vrouter-dkms \
     contrail-vrouter-utils \
     contrail-vrouter-init
RUN apt-get install -y --force-yes python-iniparse

COPY entrypoint.sh /
COPY openstack-config /
COPY vrouter-functions.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-vrouter-agent"]
