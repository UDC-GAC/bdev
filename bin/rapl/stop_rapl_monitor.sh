#!/bin/bash

for NODE in $WORKERNODES $MASTERNODE
do
	$SSH_CMD $NODE "killall -u $USER -q -9 rapl_plot"
done
