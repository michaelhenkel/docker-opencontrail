docker run -d --net host \
  -v /dockervolumes/shared:/shared \
  -v /dockervolumes/cassandra1/var/lib/cassandra/data:/var/lib/cassandra/data \
  --name cassandra1 cassandra:latest
