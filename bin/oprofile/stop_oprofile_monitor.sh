#!/bin/bash

for NODE in $WORKERNODES $MASTERNODE
do
	$SSH_CMD $NODE "killall -u $USER -q -SIGINT $OPROFILE_BIN"
done
