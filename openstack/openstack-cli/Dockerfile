FROM muccg/openstackbase:kilo
MAINTAINER https://github.com/muccg/

RUN apt-get -qqy update && apt-get install -y --no-install-recommends \
  patch \
  mysql-client \
  python-ceilometerclient \
  python-cinderclient \
  python-glanceclient \
  python-heatclient \
  python-keystoneclient \
  python-mysqldb \
  python-neutronclient \
  python-novaclient \
  python-swiftclient \
  python-troveclient \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# temporary fix for kilo, see: https://bugs.launchpad.net/python-glanceclient/+bug/1342080
COPY glanceclient-fix-http.patch /root/glanceclient-fix-http.patch
RUN cd /usr/lib/python2.7/dist-packages/glanceclient/common && \
  patch -p0 < /root/glanceclient-fix-http.patch && \
  rm /usr/lib/python2.7/dist-packages/glanceclient/common/http.pyc

CMD ["/bin/sh"]
