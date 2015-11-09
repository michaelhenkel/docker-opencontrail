for i in nova analytics control neutron-server config ifmap vrouter-agent webui nova-compute
do
    cd ../contrail/$i && version=`grep "deb http" Dockerfile |awk -F "/" '{print $4}'` && docker build -t localhost:5100/$i:$version . && docker push localhost:5100/$i:$version
    cd - > /dev/null
done

