#!/bin/bash

if [[ $HADOOP_SERIES == "3" ]]
then
	$COMMON_SRC_DIR/bin/start_hadoop_yarn_3.sh
else
	$COMMON_SRC_DIR/bin/start_hadoop_yarn_2.sh
fi

sleep 10
