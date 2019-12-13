#!/bin/sh

for SLAVE in $SLAVENODES $MASTERNODE
do
	ssh $SLAVE "killall -q rapl_plot"
done
