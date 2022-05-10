#!/bin/sh

for SLAVE in $SLAVENODES $MASTERNODE
do
	ssh $SLAVE "killall -u $USER -q -SIGINT ocount"
done
