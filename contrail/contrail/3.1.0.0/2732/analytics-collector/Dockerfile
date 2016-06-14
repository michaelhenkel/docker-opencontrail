FROM michaelhenkel/analytics:3.1.0.0-2732
ENV DEBIAN_FRONTEND noninteractive

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
COPY supervisor/collector.conf /etc/supervisor/conf.d/collector.conf
#COPY supervisor/redis.conf /etc/supervisor/conf.d/redis.conf
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf", "-n"]

#CMD ["/usr/bin/contrail-collector"]
LABEL net.juniper.contrail=analytics
LABEL net.juniper.node=controller
