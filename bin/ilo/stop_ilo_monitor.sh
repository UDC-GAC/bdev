#!/bin/sh

PROCESSES=`ssh $ILO_MASTER 'ps -elf' | grep "ilo_monitor" | grep -v "stop_ilo_monitor" | tr -s " "`
echo "$PROCESSES" >> ${POWERLOGDIR}/log
PIDS=`echo "$PROCESSES" | cut -f 4 -d " "`

for PID in $PIDS
do 
	ssh $ILO_MASTER "kill -9 $PID" >> ${POWERLOGDIR}/log 2>&1
done
