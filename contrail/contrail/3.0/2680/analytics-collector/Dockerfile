FROM michaelhenkel/analytics:3.0-2680
ENV DEBIAN_FRONTEND noninteractive

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/contrail-collector"]
LABEL net.juniper.contrail=analytics
LABEL net.juniper.node=controller
