#!/bin/bash

if [ $# -ne 2 ]; then
       echo "$0 IP hostfile"
       exit -1
fi

FILE=$2
IP=$1

while read i
do
	NODE_IP=`echo $i | cut -d " " -f 2`
        if [[ $NODE_IP == "127.0.0.1" ]]
        then
          echo "localhost"
          break
        fi
        
        if [[ $NODE_IP == $IP ]]
        then
        	NODE_NAME=`echo $i | cut -d " " -f 1`
        	echo $NODE_NAME
                break
        fi
done < $FILE

