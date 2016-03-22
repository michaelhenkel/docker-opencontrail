FROM ubuntu:14.04.3
ENV DEBIAN_FRONTEND noninteractive
RUN echo "deb http://localhost/contrail/3.0/1234/ amd64/" >> /etc/apt/sources.list/
RUN apt-get update
RUN apt-get install -y --force-yes contrail-utils python-contrail contrail-lib \
     contrail-analytics

CMD ["/bin/sh"]
