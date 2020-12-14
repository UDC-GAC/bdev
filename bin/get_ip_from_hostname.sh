#!/bin/bash

if [ $# -ne 1 ]; then
       echo "$0 hostfile"
       exit -1
fi

FILE=$1
IP=""

NAME=`echo $HOSTNAME | cut -d "." -f 1`

while read i
do
	NODE=`echo $i | awk '{print $1}' | cut -d "." -f 1`
        if [[ $NODE == "localhost" ]]
        then
          echo "127.0.0.1"
          break
        fi
        
        if [[ $NODE == $NAME ]]
        then
        	IP=`echo $i | cut -d " " -f 2`
        	echo $IP
                break
        fi
done < $FILE

