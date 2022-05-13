#!/bin/bash

if [ $# -lt 1 ]; then
       echo "$0 hostfile [loopback]"
       exit -1
fi

FILE=$1
IP=""

if [ $# -eq 2 ]; then
	LOOPBACK_IP=$2
else
	LOOPBACK_IP=127.0.0.1
fi

NAME=`echo $HOSTNAME | cut -d "." -f 1`

while read i
do
	NODE=`echo $i | awk '{print $1}' | cut -d "." -f 1`
        if [[ $NODE == "localhost" ]]
        then
          echo $LOOPBACK_IP
          break
        fi
        
        if [[ $NODE == $NAME ]]
        then
        	IP=`echo $i | awk '{print $2}'`
        	echo $IP
                break
        fi
done < $FILE

