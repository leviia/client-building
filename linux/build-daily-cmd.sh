#!/bin/bash

set -xe

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DATE=`date +%Y%m%d`

mkdir -p $PWD/output/$DATE
mkdir -p $PWD/logs

if [ ! -d "$PWD/desktop" ] ; then
    git clone --depth 1 https://github.com/leviia/desktop.git
else
    cd $PWD/desktop
#    git pull
    cd -
fi

#Build
docker run \
    --name desktop-$DATE \
    -v $DIR:/input \
    -v $PWD/desktop:/desktop \
    -v $PWD/output/$DATE:/output \
    -e "APP_NAME=$1" \
    -e "APP_BUNDLE=$2" \
    -e "APP_CMD=1" \
    ghcr.io/nextcloud/continuous-integration-client-appimage:client-appimage-2 \
    /input/build-appimage-daily.sh $(id -u)

#Save the logs!
docker logs desktop-$DATE > $PWD/logs/$DATE

#Kill the container!
docker rm desktop-$DATE

#Copy to the download server
#scp ~/output/$DATE/*.AppImage daily_desktop_uploader@download.nextcloud.com:/var/www/html/desktop/daily/Linux

# remove all but the latest 5 dailies
/bin/ls -t $PWD/output | awk 'NR>6' | xargs rm -fr
