FROM michaelhenkel/webui:3.0-23b51ef
ENV DEBIAN_FRONTEND noninteractive
WORKDIR /usr/src/contrail/contrail-web-core

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/node","webServerStart.js"]
LABEL net.juniper.contrail=webui
LABEL net.juniper.node=controller
