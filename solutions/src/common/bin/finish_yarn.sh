#!/bin/bash

if [[ -v FINISH_YARN_FORCE && "$FINISH_YARN_FORCE" == "true" ]]; then
  SLAVES=`cat $SLAVESFILE`
  for slave in $SLAVES
  do
	  m_echo "Finishing NodeManager:" $slave
    $SSH_CMD $slave "${LOAD_JAVA_COMMAND}; ${METHOD_BIN_DIR}/kill.sh $JPS NodeManager"
  done

  m_echo "Finishing ResourceManager:" $MASTERNODE
  $SSH_CMD $MASTERNODE "${LOAD_JAVA_COMMAND}; ${METHOD_BIN_DIR}/kill.sh $JPS ResourceManager"

  if [[ $TIMELINE_SERVER == "true" ]]
  then
	  m_echo "Finishing ApplicationHistoryServer:" $MASTERNODE
	  $SSH_CMD $MASTERNODE "${LOAD_JAVA_COMMAND}; ${METHOD_BIN_DIR}/kill.sh $JPS ApplicationHistoryServer"
  fi

  if [[ $MR_JOBHISTORY_SERVER == "true" ]]
  then
	  m_echo "Finishing JobHistoryServer:" $MASTERNODE
	  $SSH_CMD $MASTERNODE "${LOAD_JAVA_COMMAND}; ${METHOD_BIN_DIR}/kill.sh $JPS JobHistoryServer"
  fi
else
  "${HADOOP_HOME}/sbin/stop-yarn.sh" --config "${HADOOP_CONF_DIR}"
fi
