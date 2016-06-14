FROM michaelhenkel/analytics:3.0-2676
ENV DEBIAN_FRONTEND noninteractive

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/python","/usr/bin/contrail-alarm-gen","-c","/etc/contrail/contrail-alarm-gen.conf"]
LABEL net.juniper.contrail=analytics
LABEL net.juniper.node=controller
LABEL net.juniper.contrail=analytics
LABEL net.juniper.node=controller
