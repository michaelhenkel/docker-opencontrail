docker run -it --net host \
  -v /dockervolumes/shared:/shared \
  --env CONTROL_SERVER=192.168.0.1 \
  --name ifmap1 michaelhenkel/ifmap:3.0-2680 /bin/bash
