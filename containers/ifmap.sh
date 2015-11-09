docker run -d --net host \
  -v /dockervolumes/shared:/shared \
  --env CONTROL_SERVER=192.168.0.1 \
  --name ifmap1 ifmap
