#!/bin/bash

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
	# Load BDEv functions
	. $BDEV_BIN_DIR/functions.sh
	check_directory_space "$TMP_DIR" "$LOCAL_DIRS"
fi
