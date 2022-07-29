#!/bin/bash

if [ $# -lt 2 ]; then
       echo "$0 hostfile IP [loopback]"
       exit -1
fi

FILE=$1
IP=$2

if [ $# -eq 3 ]; then
	LOOPBACK_IP=$3
else
	LOOPBACK_IP=127.0.0.1
fi

if [[ $LOOPBACK_IP == $IP ]]; then
	echo "localhost"
else
	while read i
	do
	        if [[ $NODE_IP == $IP ]]; then
	        	NODE_NAME=`echo $i | awk '{print $1}'`
	        	echo $NODE_NAME
	                break
	        fi
	done < $FILE
fi
