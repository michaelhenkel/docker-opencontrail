FROM michaelhenkel/analytics:3.0.1-e24cc66
ENV DEBIAN_FRONTEND noninteractive

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/python","/usr/bin/contrail-analytics-api","-c","/etc/contrail/contrail-analytics-api.conf"]
LABEL net.juniper.contrail=analytics
LABEL net.juniper.node=controller
