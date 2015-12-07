FROM ubuntu:14.04.3
ENV DEBIAN_FRONTEND noninteractive
RUN echo "deb http://10.87.64.23/contrail/3.0/2680/ amd64/" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y --force-yes contrail-utils python-contrail contrail-lib \
     contrail-analytics

CMD ["/bin/sh"]
