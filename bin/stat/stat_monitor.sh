#!/bin/bash

DISKS=$(lsblk -dn -a -b -o NAME,TYPE,SIZE,RM --pairs |
    awk '
        /TYPE="disk"/ &&
        $0 !~ /SIZE=""/ &&
        $0 !~ /SIZE="0"/ {
            match($0, /NAME="[^"]+"/)
            print substr($0, RSTART+6, RLENGTH-7)
        }
    ' |
    paste -sd, -)

echo "Detected disks in $HOSTNAME: ${DISKS}" >&2

"${PYTHON_BIN}" "${DOOL_COMMAND}" ${DOOL_OPTIONS} "${DISKS}" \
    --output "${STATLOGFILE}" "${STAT_SECONDS_INTERVAL}"
