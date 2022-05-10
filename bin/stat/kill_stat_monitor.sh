#!/bin/sh

DOOL_PID=`ps -elf | grep ${PYTHON3_BIN} | grep ${DOOL_COMMAND_NAME} | grep -v "ssh" | grep -v "export" | awk '{print $4}'`

if [[ \"x$DOOL_PID\" != \"x\" ]]; then
	DOOL_PID=`echo $DOOL_PID`
	echo "$HOSTNAME: cleaning up ${DOOL_COMMAND_NAME} with PID $DOOL_PID"
	kill -9 $DOOL_PID
fi
