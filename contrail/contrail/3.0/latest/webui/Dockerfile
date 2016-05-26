FROM ubuntu:14.04
ENV DEBIAN_FRONTEND noninteractive
RUN echo "deb http://10.87.64.33/contrail/ amd64/" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y --force-yes supervisor contrail-utils python-contrail contrail-lib \
     contrail-web-core contrail-web-controller

CMD ["/bin/sh"]
