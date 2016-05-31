FROM michaelhenkel/webui:3.1.0.0-2732
ENV DEBIAN_FRONTEND noninteractive
WORKDIR /var/lib/contrail-webui/contrail-web-core
COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/nodejs","jobServerStart.js"]
LABEL net.juniper.contrail=webui
LABEL net.juniper.node=controller
