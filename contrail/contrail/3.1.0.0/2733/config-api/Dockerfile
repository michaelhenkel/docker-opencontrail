FROM michaelhenkel/config:3.1.0.0-2733
ENV DEBIAN_FRONTEND noninteractive

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
COPY supervisor/config-api.conf /etc/supervisor/conf.d/config-api.conf
COPY supervisor/ifmap-server.conf /etc/supervisor/conf.d/ifmap-server.conf
#CMD ["/usr/bin/python","/usr/bin/contrail-api","--conf_file","/etc/contrail/contrail-api.conf","--conf_file","/etc/contrail/contrail-keystone-auth.conf","--worker_id","0"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf", "-n"]
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
