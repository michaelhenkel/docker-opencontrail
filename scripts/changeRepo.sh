version=$1
build=$2
repoIp=$3
cp -r ../contrail/contrail/$version/latest ../contrail/contrail/$version/$build
if [ -z $1 ]; then
    echo "need repo version"
    exit
fi
if [ -z $2 ]; then
    echo "need build number"
    exit
fi
while IFS= read -r line; do 
    sed -i "/deb http/c\RUN echo \"deb http:\/\/$repoIp\/contrail\/$version\/$build\/ amd64\/\" >> \/etc\/apt\/sources.list" $line
done < <(find ../contrail/contrail/$version/$build -name Dockerfile)
