#!/bin/sh

ln -s $UDA_LIB_DIR/uda-hadoop-2.x.jar $HADOOP_HOME/share/hadoop/common/lib/

$COMMON_SRC_DIR/bin/start_hadoop_yarn.sh
