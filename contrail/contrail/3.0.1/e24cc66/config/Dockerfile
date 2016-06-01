FROM ubuntu:14.04.3
ENV DEBIAN_FRONTEND noninteractive
RUN sed -i "s/archive.ubuntu.com/us.archive.ubuntu.com/g" /etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6839FE77
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys D4865D83
RUN echo "deb http://ppa.launchpad.net/mhenkel-3/opencontrail/ubuntu trusty main" >> /etc/apt/sources.list
RUN echo "deb http://ppa.launchpad.net/opencontrail/ppa/ubuntu trusty main" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y --force-yes contrail-utils python-contrail contrail-lib \
     contrail-config contrail-config-openstack python-iniparse
COPY openstack-config /
CMD ["/bin/sh"]
