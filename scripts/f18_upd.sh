#!/bin/bash

PATH=/bin:/usr/bin:/usr/local/bin:/opt/knowhowERP/bin:/opt/knowhowERP/util
VER=1.0.0
DAT=22.11.2013
SERVICE=$(ps ax | grep -v grep | grep -c 'F18$') 
DEST=/opt/knowhowERP/bin

sleep 3

while  [ "$SERVICE" -gt 0 ]
	do	
    	echo "$SERVICE je pokrenut cekam da se zatvori"
        sleep 5  
    done
    	gzip -dNf $1
    	mv F18 $DEST
    	chmod +x $DEST/F18
    	echo "update je zavrsen"

exit 0

