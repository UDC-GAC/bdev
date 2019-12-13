#!/usr/bin/env bash
# capture CTRL+C, CTRL+Z and quit singles using the trap
trap 'exit' SIGINT
trap 'exit' SIGQUIT
trap 'exit' SIGTSTP


if [ ! -d "$NETHOGS_BINARIES_PATH" ]; then
    echo "Error, nethogs is not installed or its installation directory '$NETHOGS_DIR' is missing."
    exit 1
fi

INTERVAL="${1:-5}"
while :
do
    echo "START"
    echo "TIMESTAMP:`date +%s`"
    echo "INTERVAL:$INTERVAL"
    $NETHOGS_BINARIES_PATH/nethogs -v 3 -t -d $INTERVAL -c 2 2> /dev/null
    result="$?"
    if [ "$result" -ne 0 ]; then
        echo "Command exited with non-zero status $result"
        exit 1
    fi
    echo "END"
    echo ""
done
