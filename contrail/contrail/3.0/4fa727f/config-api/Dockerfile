FROM michaelhenkel/config:3.0-4fa727f
ENV DEBIAN_FRONTEND noninteractive

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
RUN apt-get update
RUN apt-get install -y --force-yes ifmap-server supervisor
COPY supervisor/config-api.conf /etc/supervisor/conf.d/config-api.conf
COPY supervisor/ifmap-server.conf /etc/supervisor/conf.d/ifmap-server.conf
#CMD ["/usr/bin/python","/usr/bin/contrail-api","--conf_file","/etc/contrail/contrail-api.conf","--conf_file","/etc/contrail/contrail-keystone-auth.conf","--worker_id","0"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf", "-n"]
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
