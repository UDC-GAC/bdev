#!/bin/sh

for SLAVE in $SLAVENODES $MASTERNODE
do
	$SSH_CMD $SLAVE "killall -u $USER -q -9 rapl_plot"
done
