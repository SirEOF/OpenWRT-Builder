#!/bin/bash

REPODIR=$(pwd)/bin/
REMOTE_PATH=/home/tiagoperalta/domains/ec2-openwrt.tiagoperalta.pt/public_html/12.09.1-EC2/
LOCAL_PATH=$(pwd)/bin/x86
USER=$1
PASS=$2
HOST=ec2-openwrt.tiagoperalta.pt
#echo 'set ftp:passive-mode false; set net:timeout 10; mirror -R '\
#        $LOCAL_PATH $REMOTE_PATH \
#        -u $USER,$PASS $HOST

echo $LOCAL_PATH
/usr/bin/lftp "-e set ftp:passive-mode false; set net:timeout 10; mirror -R "$LOCAL_PATH"  "$REMOTE_PATH -u $USER,$PASS $HOST
