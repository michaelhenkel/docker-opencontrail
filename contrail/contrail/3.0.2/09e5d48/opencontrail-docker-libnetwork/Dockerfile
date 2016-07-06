FROM ubuntu:14.04
ENV DEBIAN_FRONTEND noninteractive
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6839FE77
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys D4865D83
RUN echo "deb http://ppa.launchpad.net/mhenkel-3/opencontrail/ubuntu trusty main" >> /etc/apt/sources.list
RUN echo "deb http://10.87.64.33/contrail/ amd64/" >> /etc/apt/sources.list
RUN echo "deb http://ppa.launchpad.net/opencontrail/ppa/ubuntu trusty main" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y --force-yes contrail-utils python-contrail python-contrail-vrouter-api \
                                   git python-pip python-yaml
RUN git clone https://github.com/michaelhenkel/opencontrail-docker-libnetwork.git /opencontrail-docker-libnetwork
RUN pip install netaddr pyroute2 uhttplib
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/python","/opencontrail-docker-libnetwork/opencontrail-libnetwork-driver.py","-f","/opencontrail-docker-libnetwork//opencontrail.conf"]
