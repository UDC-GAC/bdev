#!/bin/sh

OCOUNT_ARGS="-s -b -f ${OPROFILELOGFILE}"

if [[ ${OPROFILE_EVENTS} != "" ]]
then
	echo "Monitoring events: ${OPROFILE_EVENTS}"
	OCOUNT_ARGS="$OCOUNT_ARGS -e ${OPROFILE_EVENTS}"
fi

${OPROFILE_BIN_DIR}/ocount $OCOUNT_ARGS

