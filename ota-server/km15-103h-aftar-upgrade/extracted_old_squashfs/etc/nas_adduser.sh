#!/bin/sh
#

USER="$1"
PASSWD="$2"

tpipe()
{
	echo $PASSWD
	sleep 1
	echo $PASSWD
	echo 'exit'
}

tpipe | adduser -h /tmp/usb/sda1 -S $USER

