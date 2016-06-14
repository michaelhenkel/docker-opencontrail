FROM michaelhenkel/analytics:3.0-latest
ENV DEBIAN_FRONTEND noninteractive

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/python","/usr/bin/contrail-snmp-collector","--device-config-file","/etc/contrail/device.ini"]
LABEL net.juniper.contrail=analytics
LABEL net.juniper.node=controller
