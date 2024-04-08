#!/bin/bash

rm -rf /tmp/hsperfdata_$USER

if [[ $FORCE_DELETE_HDFS == "true" ]]; then
	rm -rf $TMP_DIR

	for LOCAL_DIR in $LOCAL_DIRS
	do
		rm -rf $LOCAL_DIR
	done
else
	find $TMP_DIR -maxdepth 1 -mindepth 1 ! -name dfs -exec rm -rf {} +

	for LOCAL_DIR in $LOCAL_DIRS
	do
		find $LOCAL_DIR -maxdepth 1 -mindepth 1 ! -name dfs -exec rm -rf {} +
	done
fi

mkdir -p $TMP_DIR $LOCAL_DIRS
