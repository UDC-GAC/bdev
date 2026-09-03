#!/bin/bash

for NODE in $SLAVENODES $MASTERNODE
do
	$SSH_CMD $NODE "killall -u $USER -q -SIGINT $OPROFILE_BIN"
done
