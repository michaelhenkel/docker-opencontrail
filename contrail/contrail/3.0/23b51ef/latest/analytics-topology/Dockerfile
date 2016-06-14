FROM michaelhenkel/analytics:3.0-23b51ef
ENV DEBIAN_FRONTEND noninteractive

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/python","/usr/bin/contrail-topology"]
LABEL net.juniper.contrail=analytics
LABEL net.juniper.node=controller
