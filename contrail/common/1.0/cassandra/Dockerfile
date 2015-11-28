FROM cassandra:latest
RUN sed -i 's/^start_rpc.*$/start_rpc: true/' /etc/cassandra/cassandra.yaml 
LABEL net.juniper.contrail=database
LABEL net.juniper.node=controller

