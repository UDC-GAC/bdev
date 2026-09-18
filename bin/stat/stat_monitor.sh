#!/bin/bash

# Disks
ALL_DISKS=$(
    lsblk -dn -a -b -o NAME,TYPE,SIZE,RM --pairs |
    awk '/TYPE="disk"/'
)

DISKS=$(
    printf '%s\n' "$ALL_DISKS" |
    awk '
        $0 !~ /SIZE=""/ &&
        $0 !~ /SIZE="0"/ {
            match($0, /NAME="[^"]+"/)
            print substr($0, RSTART+6, RLENGTH-7)
        }
    ' |
    sort |
    paste -sd, -
)

# Network interfaces
ALL_INTERFACES=$(
    awk '
        NR > 2 {
            line = $0
            sub(/^[[:space:]]+/, "", line)
            split(line, f, /[[:space:]:]+/)

            name = f[1]
            rx   = f[2]
            tx   = f[10]

            printf "%s %s %s\n", name, rx, tx
        }
    ' /proc/net/dev
)

INTERFACES=$(
    printf '%s\n' "$ALL_INTERFACES" |
    while read -r IFACE RX TX; do

        # Same exclusions as dool
        [[ "$IFACE" == "lo" || "$IFACE" == "face" ]] && continue

        # Same traffic criterion as dool
        [[ "$RX" == "0" && "$TX" == "0" ]] && continue

        # Exclude empty bridges
        if [[ -d "/sys/class/net/$IFACE/bridge" ]] &&
           [[ -z "$(ls -A "/sys/class/net/$IFACE/brif" 2>/dev/null)" ]]; then
            continue
        fi

        printf '%s\n' "$IFACE"
    done |
    sort |
    paste -sd, -
)

echo "Detected disks in $HOSTNAME: ${ALL_DISKS}" >&2
echo "Detected network interfaces in $HOSTNAME: ${ALL_INTERFACES}" >&2
echo "Selected disks in $HOSTNAME: ${DISKS}" >&2
echo "Selected network interfaces in $HOSTNAME: ${INTERFACES}" >&2

"${PYTHON_BIN}" "${DOOL_COMMAND}" ${DOOL_OPTIONS} -D "${DISKS}" -N "${INTERFACES}" \
    --output "${STATLOGFILE}" "${STAT_SECONDS_INTERVAL}"
