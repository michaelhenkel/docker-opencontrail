FROM ubuntu:14.04
ENV DEBIAN_FRONTEND noninteractive

RUN mkdir -p /etc/contrail
RUN mkdir -p /var/log/contrail
RUN echo "deb http://10.87.64.23/contrail/ amd64/" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y --force-yes ifmap-server

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/bin/sh","/usr/bin/ifmap-server"]
