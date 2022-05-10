#!/bin/sh

if [ $# -ne 2 ]; then
       echo "$0 JPS_CMD JAVA_APP"
       exit -1
fi

DAEMON_PIDS=`$1 | egrep $2 | cut -f 1 -d " "`
DAEMON_PIDS=`echo $DAEMON_PIDS`

if [ ! -z "$DAEMON_PIDS" ]
then
	kill -9 $DAEMON_PIDS
fi
