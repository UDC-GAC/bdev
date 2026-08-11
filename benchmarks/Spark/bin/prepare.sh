#!/bin/sh

if [ -v FINISH_YARN ] && [ "$FINISH_YARN" == "true" ]; then
	export FINISH_YARN_FORCE=true
	${COMMON_SRC_DIR}/bin/finish_yarn.sh
fi
