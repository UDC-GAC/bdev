#!/bin/bash

# Node remote probe & cleanup helper

ETH_IFACE="${1:-}"
IB_IFACE="${2:-}"
CHECK_SHARED_DIRS="${3:-}"
NODE_ID="${4:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Preventive cleaning of existing processes
if [[ -f "$SCRIPT_DIR/kill-process.sh" ]]; then
    "$SCRIPT_DIR/kill-process.sh" || true
fi

# Active shared storage check across all target directories
if [[ -n "$CHECK_SHARED_DIRS" && -n "$NODE_ID" ]]; then
    for dir in $CHECK_SHARED_DIRS; do
        if [[ -d "$dir" ]]; then
            echo "$NODE_ID" > "$dir/.bdev_probe_${NODE_ID}" 2>/dev/null || true
        fi
    done
fi

# IP extraction
get_ip() {
    local dev="$1"
    [[ -z "$dev" ]] && echo "NONE" && return
    local ip
    local cmd="${IP_COMMAND:-ip}"
    ip=$($cmd a s "$dev" 2>/dev/null | awk '/inet / {print $2}' | cut -d '/' -f 1 | head -n 1)
    echo "${ip:-NONE}"
}

ETH_IP=$(get_ip "$ETH_IFACE")
IB_IP=$(get_ip "$IB_IFACE")

# Structured output
echo "__BDEV_NET__:${ETH_IP}:${IB_IP}"
