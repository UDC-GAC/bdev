#!/bin/sh

$COMMON_SRC_DIR/bin/stop_hadoop_yarn.sh

rm $HADOOP_HOME/share/hadoop/common/lib/uda-*
