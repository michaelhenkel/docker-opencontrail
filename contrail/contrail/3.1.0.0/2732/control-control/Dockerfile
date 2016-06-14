FROM michaelhenkel/control:3.1.0.0-2732
ENV DEBIAN_FRONTEND noninteractive

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/contrail-control"]
LABEL net.juniper.contrail=control
LABEL net.juniper.node=controller
