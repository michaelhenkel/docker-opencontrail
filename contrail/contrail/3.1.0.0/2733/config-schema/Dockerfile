FROM michaelhenkel/config:3.1.0.0-2733
ENV DEBIAN_FRONTEND noninteractive

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/python","/usr/bin/contrail-schema","--conf_file","/etc/contrail/contrail-schema.conf","--conf_file","/etc/contrail/contrail-keystone-auth.conf"]
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
