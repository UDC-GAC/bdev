#!/bin/bash

echo "Performing dynamic detection of disks and network interfaces in $HOSTNAME:" >&2

USE_DISKS=1
USE_INTERFACES=1
USE_IB=1

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

# Network interfaces
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
    echo "WARNING: failed to detect network interfaces" >&2
    USE_INTERFACES=0
    INTERFACES=""
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
        echo "WARNING: failed to filter network interfaces or no suitable interfaces found" >&2
        USE_INTERFACES=0
        INTERFACES=""
    fi
fi

# InfiniBand / RoCE interfaces
if ALL_IB_INTERFACES=$(
    for DEVICE in /sys/class/infiniband/*; do
        [[ -d "$DEVICE" ]] || continue

        DEVICE_NAME=$(basename "$DEVICE")

        for PORT in "$DEVICE"/ports/*; do
            [[ -d "$PORT" ]] || continue

            PORT_NUMBER=$(basename "$PORT")
            STATE=$(cat "$PORT/state" 2>/dev/null) || exit 1

            printf "%s:%s %s\n" "$DEVICE_NAME" "$PORT_NUMBER" "$STATE"
        done
    done
); then
    echo "Detected InfiniBand/RoCE interfaces:" >&2

    if [[ -n "$ALL_IB_INTERFACES" ]]; then
        printf '%s\n' "$ALL_IB_INTERFACES" >&2
    else
        echo "(none)" >&2
    fi
else
    echo "WARNING: failed to detect InfiniBand/RoCE interfaces. Running dool without --ib" >&2
    USE_IB=0
    IB_INTERFACES=""
fi

if (( USE_IB )); then
    if IB_INTERFACES=$(
        printf '%s\n' "$ALL_IB_INTERFACES" |
        awk '$2 == "ACTIVE" { print $1 }' |
        sort |
        paste -sd, -
    ); then

        if [[ -n "$IB_INTERFACES" ]]; then
            echo "Filtered InfiniBand/RoCE interfaces: ${IB_INTERFACES}" >&2
        else
            echo "No active InfiniBand/RoCE interfaces found. Running dool without --ib" >&2
            USE_IB=0
        fi

    else
        echo "WARNING: failed to filter InfiniBand/RoCE interfaces. Running dool without --ib" >&2
        USE_IB=0
        IB_INTERFACES=""
    fi
fi

# Build final -N list
NETWORK_INTERFACES="${INTERFACES}"

if (( USE_IB )); then
    if [[ -n "$NETWORK_INTERFACES" ]]; then
        NETWORK_INTERFACES="${NETWORK_INTERFACES},${IB_INTERFACES}"
    else
        NETWORK_INTERFACES="${IB_INTERFACES}"
    fi
fi

if [[ -n "$NETWORK_INTERFACES" ]]; then
    echo "Final network interfaces for dool: ${NETWORK_INTERFACES}" >&2
else
    echo "No network interfaces selected for dool. Running without -N" >&2
fi

# Build dool command
DOOL_CMD=( "${PYTHON_BIN}" "${DOOL_COMMAND}" )
read -r -a DOOL_OPTION_ARGS <<< "${DOOL_OPTIONS}"
DOOL_CMD+=( "${DOOL_OPTION_ARGS[@]}" )

if (( USE_DISKS )); then
    DOOL_CMD+=( -D "${DISKS}" )
fi

if [[ -n "$NETWORK_INTERFACES" ]]; then
    DOOL_CMD+=( -N "${NETWORK_INTERFACES}" )
fi

if (( USE_IB )); then
    DOOL_CMD+=( --ib )
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
