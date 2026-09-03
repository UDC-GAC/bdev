#!/bin/bash

for NODE in $SLAVENODES $MASTERNODE
do
	$SSH_CMD $NODE "killall -u $USER -q -9 rapl_plot"
done
