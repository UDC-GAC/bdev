#!/bin/sh

for SLAVE in $SLAVENODES $MASTERNODE
do
	ssh $SLAVE "killall -q ${PYTHON2_BIN}"
done
