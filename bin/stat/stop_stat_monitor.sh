#!/bin/sh

for SLAVE in $MASTERNODE $SLAVENODES
do
	echo "Stopping dstat/dool monitor in ${SLAVE}" >> ${STATLOGDIR}/log 2>&1
	ssh $SLAVE "pkill -u $USER -9 -f ${DOOL_COMMAND}" >> ${STATLOGDIR}/log 2>&1
done
