FROM michaelhenkel/config:3.0-4fa727f
ENV DEBIAN_FRONTEND noninteractive

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/python","/usr/bin/contrail-discovery","--conf_file","/etc/contrail/contrail-discovery.conf","--worker_id","0"]
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
