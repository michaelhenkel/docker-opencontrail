FROM ubuntu:14.04
ENV DEBIAN_FRONTEND noninteractive
RUN echo "deb http://10.87.64.23/contrail-3.0-2668/ amd64/" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y --force-yes contrail-utils python-contrail python-contrail-vrouter-api \
                                   git python-pip
RUN git clone https://github.com/michaelhenkel/opencontrail-docker-libnetwork.git /opencontrail-docker-libnetwork
RUN pip install netaddr pyroute2 uhttplib
RUN apt-get install -y --force-yes python-yaml
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/python","/opencontrail-docker-libnetwork/opencontrail-libnetwork-driver.py","-f","/opencontrail-docker-libnetwork//opencontrail.conf"]
