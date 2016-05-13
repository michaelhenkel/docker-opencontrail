version=$1
build=$2
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
    sed -i "/deb http/c\RUN echo \"deb http:\/\/ppa.launchpad.net\/mhenkel-3\/opencontrail\/ubuntu trusty main\" >> \/etc\/apt\/sources.list" $line
done < <(find ../contrail/contrail/$version/$build -name Dockerfile)

while IFS= read -r line; do
    service=`echo $line|awk -F"/" '{print $6}'|awk -F"-" '{print $1}'`
    sed "/FROM michaelhenkel/c\FROM michaelhenkel/$service:$version-$build" $line
done < <(grep -r "FROM michaelhenkel" ../contrail/contrail/$version/$build |awk -F":" '{print $1}')
