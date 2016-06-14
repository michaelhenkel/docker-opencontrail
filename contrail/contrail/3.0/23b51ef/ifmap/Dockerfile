FROM ubuntu:14.04.3
ENV DEBIAN_FRONTEND noninteractive
RUN mkdir -p /etc/contrail
RUN mkdir -p /var/log/contrail
RUN echo "deb http://172.16.8.132/contrail/3.0/23b51ef/ amd64/" >> /etc/apt/sources.list
RUN echo "deb http://ppa.launchpad.net/opencontrail/ppa/ubuntu trusty main" >> /etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6839FE77
RUN apt-get update
RUN apt-get install -y --force-yes ifmap-server

LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/bin/sh","/usr/bin/ifmap-server"]
