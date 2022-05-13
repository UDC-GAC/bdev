#!/bin/bash

if [ $# -lt 1 ]; then
       echo "$0 hostfile"
       exit -1
fi

FILE=$1

NAME=`echo $HOSTNAME | cut -d "." -f 1`

while read i
do
	NODE=`echo $i | awk '{print $1}' | cut -d "." -f 1`
        if [[ $NODE == "localhost" ]]
        then
          echo "localhost"
          break
        fi
        
        if [[ $NODE == $NAME ]]
        then
        	NODE_NAME=`echo $i | awk '{print $1}'`
        	echo $NODE_NAME
                break
        fi
done < $FILE

