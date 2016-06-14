FROM michaelhenkel/control:3.0-2676
ENV DEBIAN_FRONTEND noninteractive

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/contrail-control"]
LABEL net.juniper.contrail=control
LABEL net.juniper.node=controller
