#!/bin/sh

sleep 2

for slave in $MASTERNODE $SLAVENODES
do
	DAEMON_PIDS=`ssh $slave "${LOAD_JAVA_COMMAND}; ${JPS}" | \
		egrep \
		"NameNode|DataNode|ResourceManager|NodeManager|JobTracker|TaskTracker|JobHistoryServer|ApplicationHistoryServer|RunJar|Child|MRAppMaster|YarnChild|MPI_D_Runner|SparkSubmit|CoarseGrainedExecutorBackend|ApplicationMaster|Master|HistoryServer|Worker|ExecutorLauncher|JobManager|TaskManager|StandaloneSessionClusterEntrypoint|TaskManagerRunner|CliFrontend" \
		| cut -f 1 -d " "`
	
	DAEMON_PIDS=`echo $DAEMON_PIDS`
	
	ssh $slave "
	if [[ \"x$DAEMON_PIDS\" != \"x\" ]];
	then
		kill -9 $DAEMON_PIDS;
	fi;
	killall -u $USER -q -9 hydra_pmi_proxy; \
	killall -u $USER -q -9 python; \
	killall -u $USER -q -9 ${PYTHON3_BIN}; \
	killall -u $USER -q -9 ocount; \
	killall -u $USER -q -9 rapl_plot; \
	rm -rf $TMP_DIR $LOCAL_DIRS /tmp/hsperfdata_$USER; \
	mkdir -p $TMP_DIR $LOCAL_DIRS"
done
