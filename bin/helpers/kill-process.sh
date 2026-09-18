#!/bin/bash

PROCESS="NameNode|SecondaryNameNode|DataNode|ResourceManager|NodeManager|JobHistoryServer|ApplicationHistoryServer|RunJar|Child|MRAppMaster|YarnChild|SparkSubmit|CoarseGrainedExecutorBackend|ApplicationMaster|Master|HistoryServer|Worker|ExecutorLauncher|JobManager|TaskManager|StandaloneSessionClusterEntrypoint|TaskManagerRunner|CliFrontend"

LOG_OUTPUT=""
JPS_MATCHES=$("$JPS" 2>/dev/null | grep -E "$PROCESS")

if [[ -n "$JPS_MATCHES" ]]; then
    PROCESS_PIDS=$(awk '{print $1}' <<< "$JPS_MATCHES")
	LOG_OUTPUT+="$HOSTNAME: cleaning up"$'\n'
    LOG_OUTPUT+=$(awk '{printf "  %s with PID %s\n", $2, $1}' <<< "$JPS_MATCHES")$'\n'
    kill -9 $PROCESS_PIDS 2>/dev/null || true
fi

if [[ -n "${DOOL_COMMAND_NAME:-}" ]]; then
    DOOL_PID=$(ps -elf \
        | grep "${PYTHON_BIN:-python}" \
        | grep "$DOOL_COMMAND_NAME" \
        | grep -v -E "grep|probe_node|kill-process|export" \
        | awk '{print $4}' \
        | grep -v -E "^($$|$PPID)$" || true)

    if [[ -n "$DOOL_PID" ]]; then
		LOG_OUTPUT+="$HOSTNAME: cleaning up ${DOOL_COMMAND_NAME} with PID(s): $DOOL_PID"$'\n'
        kill -9 $DOOL_PID 2>/dev/null || true
    fi
fi

if [[ "$ENABLE_OPROFILE" == "true" && -n "${OPROFILE_BIN:-}" ]]; then
	killall -u "$USER" -q -9 "${OPROFILE_BIN##*/}" 2>/dev/null || true
fi

if [[ "$ENABLE_RAPL" == "true" && -n "${RAPL_TOOL_BIN:-}" ]]; then
	killall -u "$USER" -q -9 "${RAPL_TOOL_BIN##*/}" 2>/dev/null || true
fi

[[ -n "$LOG_OUTPUT" ]] && printf "%s" "$LOG_OUTPUT"

exit 0
