#!/bin/sh

for SLAVE in $SLAVENODES $MASTERNODE
do
	ssh $SLAVE "killall -SIGINT ocount"
done
