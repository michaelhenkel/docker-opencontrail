FROM ubuntu:14.04.3
ENV DEBIAN_FRONTEND noninteractive
RUN sed -i "s/archive.ubuntu.com/us.archive.ubuntu.com/g" /etc/apt/sources.list
RUN echo "deb http://10.87.64.33/contrail/ amd64/" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y --force-yes contrail-utils python-contrail contrail-lib \
     contrail-control contrail-dns python-iniparse
COPY openstack-config /

CMD ["/bin/sh"]
