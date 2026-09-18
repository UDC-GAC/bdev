#!/bin/bash

echo "Performing dynamic detectioln of disks and network interfaces in $HOSTNAME:" >&2

USE_DISKS=1
USE_INTERFACES=1

# Disks
if ALL_DISKS=$(
    lsblk -dn -a -b -o NAME,TYPE,SIZE,RM --pairs |
    awk '/TYPE="disk"/'
); then
    echo "Detected disks:" >&2
    printf '%s\n' "$ALL_DISKS" >&2
else
    echo "WARNING: failed to detect disks. Running dool without -D" >&2
    USE_DISKS=0
fi

if (( USE_DISKS )); then
    if DISKS=$(
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
    ) && [[ -n "$DISKS" ]]; then
        echo "Filtered disks: ${DISKS}" >&2
    else
        echo "WARNING: failed to filter disks or no suitable disks found. Running dool without -D" >&2
        USE_DISKS=0
        DISKS=""
    fi
fi

if ALL_INTERFACES=$(
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
); then
    echo "Detected network interfaces:" >&2
    printf '%s\n' "$ALL_INTERFACES" >&2
else
    echo "WARNING: failed to detect network interfaces. Running dool without -N." >&2
    USE_INTERFACES=0
fi

if (( USE_INTERFACES )); then
    if INTERFACES=$(
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
    ) && [[ -n "$INTERFACES" ]]; then
        echo "Filtered network interfaces: ${INTERFACES}" >&2
    else
        echo "WARNING: failed to filter network interfaces or no suitable interfaces found. Running dool without -N." >&2
        USE_INTERFACES=0
        INTERFACES=""
    fi
fi

# Build dool command

DOOL_CMD=( "${PYTHON_BIN}" "${DOOL_COMMAND}" )
read -r -a DOOL_OPTION_ARGS <<< "${DOOL_OPTIONS}"
DOOL_CMD+=( "${DOOL_OPTION_ARGS[@]}" )

if (( USE_DISKS )); then
    DOOL_CMD+=( -D "${DISKS}" )
fi

if (( USE_INTERFACES )); then
    DOOL_CMD+=( -N "${INTERFACES}" )
fi

DOOL_CMD+=(
    --output "${STATLOGFILE}"
    "${STAT_SECONDS_INTERVAL}"
)

# Print and execute command
printf 'Running: ' >&2
printf '%q ' "${DOOL_CMD[@]}" >&2
printf '\n' >&2

"${DOOL_CMD[@]}"
