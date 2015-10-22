docker run -d --net host \
  -v /dockervolumes/shared:/shared \
  --env CTRL_NODES=host1 \
  --name ifmap1 ifmap
