repoIp=10.87.64.23
repoVersion=$1
if [ -z $1 ]; then
    echo "need repo version"
    exit
fi
while IFS= read -r line; do 
    repo=`echo $line |awk '{print $4}'`
    file=`echo $line|awk -F":" '{print $1}'`
    repoName=`echo $repo |awk -F"/" '{print $4}'`
    echo $repo
    echo $repoName
    echo $file
#    sed -i "s/http:\/\/$repoIp\/$repoName/http:\/\/$repoIp\/$repoVersion/g" $file
done < <(grep -r "deb http://$repoIp/" ../contrail)
