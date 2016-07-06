FROM michaelhenkel/control:3.0.2-09e5d48
ENV DEBIAN_FRONTEND noninteractive

COPY entrypoint.sh /
COPY supervisor/dns.conf /etc/supervisor/conf.d/dns.conf
COPY supervisor/named.conf /etc/supervisor/conf.d/named.conf
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf", "-n"]
#CMD ["/usr/bin/contrail-named","-f","-g","-u","contrail","-c","/etc/contrail/dns/contrail-named.conf"]
LABEL net.juniper.contrail=control
LABEL net.juniper.node=controller
