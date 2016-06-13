FROM michaelhenkel/control:3.0.1-e24cc66
ENV DEBIAN_FRONTEND noninteractive

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/contrail-dns"]
LABEL net.juniper.contrail=control
LABEL net.juniper.node=controller
