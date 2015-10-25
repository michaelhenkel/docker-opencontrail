#!/bin/sh
#
# Script to build images
#

# break on error
set -e

DATE=`date +%Y.%m.%d`
BRANCH='kilo'

# ensure we build base first, everything extends from this
docker pull muccg/openstackbase:${BRANCH} || true
docker build -t muccg/openstackbase:${BRANCH} openstackbase

# build sub dirs
for dir in */
do
    dir=${dir%*/}
    echo "################################################################### ${dir##*/}"

    # blindly pull what we are trying to build
    # at the very least this should ensure the build server has the latest image from this branch
    docker pull muccg/${dir}:${BRANCH} || true
    docker pull muccg/${dir}:${BRANCH}.${DATE} || true

    # build
    docker build -t muccg/${dir}:${BRANCH}.${DATE} ${dir}
    docker build -t muccg/${dir}:${BRANCH} ${dir}

    # push
    docker push muccg/${dir}:${BRANCH}.${DATE}
    docker push muccg/${dir}:${BRANCH}
done
