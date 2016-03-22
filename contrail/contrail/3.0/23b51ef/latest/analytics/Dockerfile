FROM ubuntu:14.04.3
ENV DEBIAN_FRONTEND noninteractive
RUN echo "deb http://172.16.8.132/contrail/3.0/23b51ef/ amd64/" >> /etc/apt/sources.list
RUN echo "deb http://ppa.launchpad.net/opencontrail/ppa/ubuntu trusty main" >> /etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6839FE77
RUN apt-get update
RUN apt-get install -y --force-yes contrail-utils python-contrail contrail-lib \
     contrail-analytics

CMD ["/bin/sh"]
