FROM michaelhenkel/webui:3.0-4fa727f
ENV DEBIAN_FRONTEND noninteractive
WORKDIR /var/lib/contrail-webui/contrail-web-core

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/nodejs","webServerStart.js"]
LABEL net.juniper.contrail=webui
LABEL net.juniper.node=controller
