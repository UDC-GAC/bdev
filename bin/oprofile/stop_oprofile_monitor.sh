#!/bin/bash

# Deduplicate nodes in case the master is also a worker
UNIQUE_NODES=$(printf '%s\n' $MASTERNODE $WORKERNODES | sort -u)

for NODE in $UNIQUE_NODES
do
	$SSH_CMD $NODE "killall -u $USER -q -SIGINT $OPROFILE_BIN"
done
