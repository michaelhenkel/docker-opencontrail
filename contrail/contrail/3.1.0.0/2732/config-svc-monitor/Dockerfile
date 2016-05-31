FROM michaelhenkel/config:3.1.0.0-2732
ENV DEBIAN_FRONTEND noninteractive

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/python","/usr/bin/contrail-svc-monitor","--conf_file","/etc/contrail/contrail-svc-monitor.conf","--conf_file","/etc/contrail/contrail-keystone-auth.conf"]
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
