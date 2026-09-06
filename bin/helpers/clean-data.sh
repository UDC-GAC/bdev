#!/bin/bash

check_disk_space() {
    local DISK_MIN_FREE_PERCENT="${DISK_SPACE_THRESHOLD:-5}"
    # Take all arguments passed to the function and replace commas with spaces
    local RAW_DIRS="${*//,/ }"
    local CHECKED_MOUNTS=()

    for dir in $RAW_DIRS; do
        [[ -z "$dir" ]] && continue

        # If the route does not yet exist, resolve the nearest ancestor that does exist.
        local target="$dir"
        while [[ ! -d "$target" && "$target" != "/" && "$target" != "." ]]; do
            target=$(dirname "$target")
        done

        [[ ! -d "$target" ]] && continue

        # Obtain total blocks ($2), free blocks ($4) and mount point ($6) in POSIX format
        local df_info
        df_info=$(df -Pk "$target" 2>/dev/null | awk 'NR==2 {print $2, $4, $6}')
        [[ -z "$df_info" ]] && continue

        local total_kb=$(echo "$df_info" | awk '{print $1}')
        local avail_kb=$(echo "$df_info" | awk '{print $2}')
        local mount_point=$(echo "$df_info" | awk '{print $3}')

        # Deduplicate: skip if this same assembly point has already been evaluated
        if [[ " ${CHECKED_MOUNTS[*]} " =~ " ${mount_point} " ]]; then
            continue
        fi
        CHECKED_MOUNTS+=("$mount_point")

        # Avoid division by zero in virtual systems or pseudofs
        (( total_kb == 0 )) && continue

        # Native integer arithmetic calculation in Bash
        local avail_pct=$(( (avail_kb * 100) / total_kb ))
        local avail_gb=$(( avail_kb / 1024 / 1024 ))

        if (( avail_pct < DISK_MIN_FREE_PERCENT )); then
            echo "Low disk space on $HOSTNAME: $mount_point ($target) | ${avail_pct}% free (${avail_gb}GB available)"
        fi
    done
}

# Cleaning of temporary files
if [[ -n "$USER" ]]; then
	rm -rf /tmp/hadoop-"$USER" /tmp/spark-"$USER" /tmp/flink-"$USER" /tmp/jna-"$USER" 2>/dev/null

	if [[ -d "/tmp/hsperfdata_${USER}" ]]; then
		rm -rf "/tmp/hsperfdata_${USER}"
	fi
fi

# Normalize separators (replace commas with spaces) and unify paths
RAW_DIRS="$TMP_DIR ${LOCAL_DIRS//,/ }"
CLEAN_DIRS=()

for dir in $RAW_DIRS; do
    # Protection: the path cannot be empty or a '/'
    if [[ -n "$dir" && "$dir" != "/" ]]; then
        # Deduplicate to avoid cleaning the same path twice
        # If dir is NOT within CLEAN_DIRS
        if [[ ! " ${CLEAN_DIRS[*]} " =~ " ${dir} " ]]; then
            CLEAN_DIRS+=("$dir")
        fi
    fi
done

for dir in "${CLEAN_DIRS[@]}"; do
	if [[ ! -d "$dir" ]]; then
		continue
	fi

	if [[ "$FORCE_DELETE_HDFS" == "true" ]]; then
		rm -rf "$dir"
	else
        # Delete top-level content except for anything named "dfs"
        find "$dir" -mindepth 1 -maxdepth 1 ! -name "dfs" -exec rm -rf {} + 2>/dev/null
    fi
done

# Recreate a clean structure for subsequent executions
# Normalize commas to spaces so that mkdir creates the actual paths
MKDIR_TARGETS="${TMP_DIR} ${LOCAL_DIRS//,/ } ${SPARK_LOCAL_DIRS//,/ } ${FLINK_LOCAL_DIRS//,/ }"

if [[ -n "${MKDIR_TARGETS// /}" ]]; then
	mkdir -p $MKDIR_TARGETS 2>/dev/null
fi

# Disk space check
if [[ "$DISK_SPACE_CHECK" == "true" ]]; then
	check_disk_space "$TMP_DIR" "$LOCAL_DIRS"
fi
