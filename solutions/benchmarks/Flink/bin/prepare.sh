#!/bin/sh

if [[ "x${FINISH_YARN}" == "xtrue" ]]
then
	${COMMON_SRC_DIR}/bin/finish_yarn.sh
fi
