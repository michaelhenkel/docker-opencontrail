FROM michaelhenkel/webui:3.0.2-09e5d48
ENV DEBIAN_FRONTEND noninteractive
WORKDIR /var/lib/contrail-webui/contrail-web-core

COPY entrypoint.sh /
COPY supervisor/job.conf /etc/supervisor/conf.d/job.conf
COPY supervisor/server.conf /etc/supervisor/conf.d/server.conf
COPY build-files.sh /var/lib/contrail-webui/contrail-web-core
RUN mkdir /var/log/contrail

ENTRYPOINT ["/entrypoint.sh"]

#CMD ["/usr/bin/nodejs","webServerStart.js"]
#ln -s /var/lib/contrail-webui/contrail-web-core/webroot/ /var/lib/contrail-webui/contrail-web-core/webroot/dist
RUN (cd /var/lib/contrail-webui/contrail-web-core; /bin/bash build-files.sh prod webController)
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf", "-n"]
LABEL net.juniper.contrail=webui
LABEL net.juniper.node=controller
