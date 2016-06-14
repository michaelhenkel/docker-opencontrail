FROM michaelhenkel/webui:3.0-latest
ENV DEBIAN_FRONTEND noninteractive
WORKDIR /var/lib/contrail-webui/contrail-web-core
COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/nodejs","jobServerStart.js"]
LABEL net.juniper.contrail=webui
LABEL net.juniper.node=controller
