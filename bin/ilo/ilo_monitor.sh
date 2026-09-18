#!/bin/bash

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <node_ip_or_hostname> [node_number]" >&2
    exit 1
fi

TARGET_NODE="$1"
NODE_NUMBER="${2:-0}"
RESOLVE_CMD="${RESOLVEIP_COMMAND:-getent}"

# Resolve the IP if a hostname is provided, ensuring the last octet is always numeric
NODE_IP="$TARGET_NODE"
if [[ ! "$TARGET_NODE" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    RESOLVED_IP=$($RESOLVE_CMD hosts "$TARGET_NODE" 2>/dev/null | awk '{print $1; exit}')
    [[ -n "$RESOLVED_IP" ]] && NODE_IP="$RESOLVED_IP"
fi

FINAL_DIGIT="${NODE_IP##*.}"
ILO_IP="${ILO_BASE_IP}.${FINAL_DIGIT}"

printf "Time(s)\tPower(w) (node-%s, Host: %s, IP: %s, iLO IP: %s)\n" \
    "$NODE_NUMBER" "$TARGET_NODE" "$NODE_IP" "$ILO_IP"

BEGIN_EPOCH=$(date +%s)
TARGET_EPOCH=$BEGIN_EPOCH

while true; do
    LOOP_EPOCH=$(date +%s)
    TARGET_EPOCH=$(( TARGET_EPOCH + ILO_SECONDS_INTERVAL ))

    NODE_POWER_READINGS=$("$ILO_CONFIG_SCRIPT" -s "$ILO_IP" -f "$ILO_POWER_SCRIPT" 2>/dev/null)

    # Extract the value of PRESENT_POWER_READING
    POWER_VAL=$(grep "PRESENT_POWER_READING" <<< "$NODE_POWER_READINGS" || true)
    POWER_VAL="${POWER_VAL##*<PRESENT_POWER_READING VALUE=\"}"
    POWER_VAL="${POWER_VAL%\" UNIT=\"Watts\"/>*}"

    CURRENT_EPOCH=$(date +%s)
    SLEEP_SECONDS=$(( TARGET_EPOCH - CURRENT_EPOCH ))
    CURRENT_TIME=$(( LOOP_EPOCH - BEGIN_EPOCH ))

    printf "%d\t%s\n" "$CURRENT_TIME" "${POWER_VAL:-0}"

    if (( SLEEP_SECONDS > 0 )); then
        sleep "$SLEEP_SECONDS"
    fi
done
