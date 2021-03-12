#!/bin/bash
for containerId in `sudo docker ps | grep "alethio/ethstats" | awk '{print $1}'`;do 
    log=`sudo docker inspect -f '{{.LogPath}}' $containerId`;
    echo "truncating logs found in:   $log ...";
    sudo truncate -s 0 $log;
done