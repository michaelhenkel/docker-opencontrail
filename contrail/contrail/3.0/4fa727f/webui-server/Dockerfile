FROM michaelhenkel/webui:3.0-4fa727f
ENV DEBIAN_FRONTEND noninteractive
WORKDIR /var/lib/contrail-webui/contrail-web-core

COPY entrypoint.sh /
COPY supervisor/job.conf /etc/supervisor/conf.d/job.conf
COPY supervisor/server.conf /etc/supervisor/conf.d/server.conf
RUN mkdir /var/log/contrail

ENTRYPOINT ["/entrypoint.sh"]

#CMD ["/usr/bin/nodejs","webServerStart.js"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf", "-n"]
LABEL net.juniper.contrail=webui
LABEL net.juniper.node=controller
