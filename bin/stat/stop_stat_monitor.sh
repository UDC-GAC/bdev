#!/bin/sh

for SLAVE in $SLAVENODES $MASTERNODE
do
	ssh $SLAVE "pkill -f ${DSTAT}"
done
