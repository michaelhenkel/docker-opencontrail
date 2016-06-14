FROM michaelhenkel/analytics:3.0-4fa727f
ENV DEBIAN_FRONTEND noninteractive

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/contrail-query-engine"]
LABEL net.juniper.contrail=analytics
LABEL net.juniper.node=controller
