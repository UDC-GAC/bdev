#!/bin/bash

DAEMONS="NameNode|DataNode|ResourceManager|NodeManager|JobTracker|TaskTracker|JobHistoryServer|ApplicationHistoryServer|RunJar|Child|MRAppMaster|YarnChild|MPI_D_Runner|SparkSubmit|CoarseGrainedExecutorBackend|ApplicationMaster|Master|HistoryServer|Worker|ExecutorLauncher|JobManager|TaskManager|StandaloneSessionClusterEntrypoint|TaskManagerRunner|CliFrontend"

DAEMON_PIDS=`${JPS} | egrep $DAEMONS | awk '{print $1}'`
DAEMON_NAMES=`${JPS} | egrep $DAEMONS | awk '{print $2}'`
	
if [[ \"x$DAEMON_PIDS\" != \"x\" ]]; then
	DAEMON_PIDS=`echo $DAEMON_PIDS`
	DAEMON_NAMES=`echo $DAEMON_NAMES`
	echo "$HOSTNAME: cleaning up $DAEMON_NAMES with PIDs $DAEMON_PIDS"
	kill -9 $DAEMON_PIDS
fi

DOOL_PID=`ps -elf | grep ${PYTHON3_BIN} | grep ${DOOL_COMMAND_NAME} | grep -v "export" | awk '{print $4}'`

if [[ \"x$DOOL_PID\" != \"x\" ]]; then
	DOOL_PID=`echo $DOOL_PID`
	echo "$HOSTNAME: cleaning up ${DOOL_COMMAND_NAME} with PID $DOOL_PID"
	kill -9 $DOOL_PID
fi

killall -u $USER -q -9 ocount
killall -u $USER -q -9 rapl_plot
rm -rf $TMP_DIR $LOCAL_DIRS /tmp/hsperfdata_$USER
mkdir -p $TMP_DIR $LOCAL_DIRS
