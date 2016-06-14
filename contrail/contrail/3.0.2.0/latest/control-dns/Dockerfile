FROM michaelhenkel/control:3.0.2.0-latest
ENV DEBIAN_FRONTEND noninteractive

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/contrail-dns"]
LABEL net.juniper.contrail=control
LABEL net.juniper.node=controller
