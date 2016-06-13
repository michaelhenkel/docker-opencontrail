FROM michaelhenkel/nodemgr:3.0.1-e24cc66
ENV DEBIAN_FRONTEND noninteractive

COPY entrypoint.sh /
COPY supervisor/nodemgr.conf /etc/supervisor/conf.d/nodemgr.conf

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf", "-n"]
#CMD ["/usr/bin/contrail-nodemgr","--nodetype=contrail-config"]
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
