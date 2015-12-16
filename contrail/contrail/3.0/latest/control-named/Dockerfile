FROM michaelhenkel/control:3.0-latest
ENV DEBIAN_FRONTEND noninteractive

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/contrail-named","-f","-g","-u","contrail","-c","/etc/contrail/dns/contrail-named.conf"]
LABEL net.juniper.contrail=control
LABEL net.juniper.node=controller
