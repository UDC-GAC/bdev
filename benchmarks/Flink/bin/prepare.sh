#!/bin/bash

if [[ -v FINISH_YARN && "$FINISH_YARN" == "true" ]]; then
	export FINISH_YARN_FORCE="true"
	"$COMMON_HADOOP_DIR/bin/stop_yarn.sh"
fi
