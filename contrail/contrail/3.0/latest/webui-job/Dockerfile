FROM michaelhenkel/webui:3.0-latest
ENV DEBIAN_FRONTEND noninteractive
WORKDIR /usr/src/contrail/contrail-web-core
COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/node","jobServerStart.js"]
LABEL net.juniper.contrail=webui
LABEL net.juniper.node=controller
