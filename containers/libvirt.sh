docker run -d --net host --privileged --cap-add NET_ADMIN \
  -v /var/lib/nova/instances:/var/lib/nova/instances \
  -v /lib/modules:/lib/modules \
  -v /var/lib/libvirt/:/var/lib/libvirt/ \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  --name libvirt1 libvirt
