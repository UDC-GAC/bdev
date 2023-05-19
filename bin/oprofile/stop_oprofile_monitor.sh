#!/bin/sh

for SLAVE in $SLAVENODES $MASTERNODE
do
	$SSH_CMD $SLAVE "killall -u $USER -q -SIGINT ocount"
done
