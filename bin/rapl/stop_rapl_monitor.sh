#!/bin/sh

for SLAVE in $SLAVENODES $MASTERNODE
do
	ssh $SLAVE "killall -u $USER -q -9 rapl_plot"
done
