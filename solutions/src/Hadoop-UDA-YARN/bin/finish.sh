#!/bin/sh

$HADOOP_HOME/sbin/stop-all.sh

bash $CLEAN_DAEMONS_SCRIPT

rm $HADOOP_HOME/share/hadoop/common/lib/uda-*
