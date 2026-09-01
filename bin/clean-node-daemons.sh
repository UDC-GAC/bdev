#!/bin/bash

DAEMONS="NameNode|SecondaryNameNode|DataNode|ResourceManager|NodeManager|JobHistoryServer|ApplicationHistoryServer|RunJar|Child|MRAppMaster|YarnChild|SparkSubmit|CoarseGrainedExecutorBackend|ApplicationMaster|Master|HistoryServer|Worker|ExecutorLauncher|JobManager|TaskManager|StandaloneSessionClusterEntrypoint|TaskManagerRunner|CliFrontend"

JPS_MATCHES=$(${JPS} 2>/dev/null | grep -E "${DAEMONS}")

if [[ -n "$JPS_MATCHES" ]]; then
    DAEMON_PIDS=$(echo "$JPS_MATCHES" | awk '{print $1}')
    DAEMON_NAMES=$(echo "$JPS_MATCHES" | awk '{print $2}')
    echo "$HOSTNAME: cleaning up $DAEMON_NAMES with PIDs $DAEMON_PIDS"
    kill -9 $DAEMON_PIDS 2>/dev/null
fi

DOOL_PID=$(ps -elf | grep "${PYTHON_BIN}" | grep "${DOOL_COMMAND_NAME}" | grep -v "export" | grep -v "grep" | awk '{print $4}')

if [[ -n "$DOOL_PID" ]]; then
    DOOL_PID=$(echo $DOOL_PID)
    echo "$HOSTNAME: cleaning up ${DOOL_COMMAND_NAME} with PID $DOOL_PID"
    kill -9 $DOOL_PID 2>/dev/null
fi

killall -u $USER -q -9 ocount
killall -u $USER -q -9 rapl_plot
