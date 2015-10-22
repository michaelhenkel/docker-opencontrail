docker run -d --net host \
  -v /dockervolumes/shared:/shared \
  -v /dockervolumes/zookeeper1/var/lib/zookeeper:/var/lib/zookeeper \
  --env ADVERTISED_HOST=10.87.64.23 \
  --env ADVERTISED_PORT=9092 \
  --name zookeeper1 spotify/kafka
