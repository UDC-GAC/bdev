#!/usr/bin/env bash
export NETHOGS_BINARIES_PATH="bin/nethogs/"
export TEMPLATE_PATH="src/pipelines/templates/"
export METRICS_PATH="src/pipelines/metrics/"
export TAGS_PATH="src/pipelines/tags/"

export PYTHONUNBUFFERED="yes"
export POST_DOC_BUFFER_TIMEOUT=5
export NETHOGS_SAMPLING_FREQUENCY=5

if [ ! -d "$NETHOGS_BINARIES_PATH" ]; then
    echo "Error, nethogs is not installed or its installation directory '$NETHOGS_BINARIES_PATH' is missing."
    exit 1
fi

tmux new -s "NETHOGS" "bash ./src/nethogs/run_nethogs.sh $NETHOGS_SAMPLING_FREQUENCY | python3 ./src/nethogs/filter_raw_output.py | python3 ./src/nethogs/nethogs_to_json.py | python3 ./src/pipelines/send_to_OpenTSDB.py"
