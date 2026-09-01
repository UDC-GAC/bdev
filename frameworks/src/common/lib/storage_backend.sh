#!/bin/bash

HDFS_CMD=("${HADOOP_HOME}/bin/hdfs" "dfs")

function get_storage_uri_prefix() {
    case "${STORAGE_BACKEND,,}" in
        hdfs)
            echo "hdfs://$MASTERNODE:$HDFS_PORT"
            ;;
        nfs)
            echo "file:${NFS_MOUNT_POINT}"
            ;;
        *)
            m_exit "Storage backend not supported: $STORAGE_BACKEND"
            ;;
    esac
}

function storage_mkdir() {
    local target_dir=$1

    # Checks
    if [[ -z "${target_dir}" ]]; then
        m_exit "storage_mkdir: Missing arguments. Usage: storage_mkdir <path>"
    fi
    
    case "${STORAGE_BACKEND,,}" in
        hdfs)
           "${HDFS_CMD[@]}" -mkdir -p "${target_dir}"
            ;;
        nfs)
            # Remove 'file://' or 'file:' prefix if it exists in the input variable
            local clean_path="${target_dir#file://}"
            clean_path="${clean_path#file:}"
            mkdir -p "${clean_path}"
            ;;
        *)
            m_exit "Storage backend not supported: $STORAGE_BACKEND"
            ;;
    esac
}

function storage_ls() {
    local recursive=""
    local target_path=""

    # Argument parsing
    if [[ "$1" == "-r" || "$1" == "-R" ]]; then
        # Force uppercase -R since both HDFS and POSIX ls use -R for recursive (-r is reverse)
        recursive="-R"
        target_path="$2"
    else
        target_path="$1"
    fi

    # Checks
    if [[ -z "${target_path}" ]]; then
	m_exit "storage_ls: Missing arguments. Usage: storage_ls [-r|-R] <path>"
    fi

    case "${STORAGE_BACKEND,,}" in
        hdfs)
            # We leave the $recursive variable without quotes so that bash can evaluate whether to inject the flag or not
            "${HDFS_CMD[@]}" -ls $recursive "${target_path}"
            ;;
        nfs)
            # Remove 'file://' or 'file:' prefix if it exists in the input variable
            local clean_path="${target_path#file://}"
            clean_path="${clean_path#file:}"
            ls $recursive "${clean_path}"
            ;;
        *)
            m_exit "Storage backend not supported: $STORAGE_BACKEND"
            ;;
    esac
}

function storage_copy_from_local() {
    local local_file=$1
    local target_dir=$2

    # Checks
    if [[ -z "${local_file}" ]] || [[ -z "${target_dir}" ]]; then
        m_exit "storage_copy_from_local: Missing arguments. Usage: storage_copy_from_local <src_local_path> <dst_remote_path>"
    fi
    
    case "${STORAGE_BACKEND,,}" in
        hdfs)
            "${HDFS_CMD[@]}" -put "${local_file}" "${target_dir}"
            ;;
        nfs)
            # Remove 'file://' or 'file:' prefix if it exists in the input variable
            local local_clean_path="${local_file#file://}"
            local_clean_path="${local_clean_path#file:}"
            local target_clean_path="${target_dir#file://}"
            target_clean_path="${target_clean_path#file:}"
            cp -r "${local_clean_path}" "${target_clean_path}"
            ;;
        *)
            m_exit "Storage backend not supported: $STORAGE_BACKEND"
            ;;
    esac
}

function storage_copy_to_local() {
    local remote_file=$1
    local local_dir=$2

    # Checks
    if [[ -z "${remote_file}" ]] || [[ -z "${local_dir}" ]]; then
        m_exit "storage_copy_to_local: Missing arguments. Usage: storage_copy_to_local <remote_src_path> <local_dst_path>"
    fi
    
    case "${STORAGE_BACKEND,,}" in
        hdfs)
            "${HDFS_CMD[@]}" -get "${remote_file}" "${local_dir}"
            ;;
        nfs)
            # Remove 'file://' or 'file:' prefix if it exists in the input variable
            local remote_clean_path="${remote_file#file://}"
            remote_clean_path="${remote_clean_path#file:}"
            local local_clean_path="${local_dir#file://}"
            local_clean_path="${local_clean_path#file:}"
            # We add -r in case you are downloading an entire directory (HDFS -get does this by default)
            cp -r "${remote_clean_path}" "${local_clean_path}"
            ;;
        *)
            m_exit "Storage backend not supported: $STORAGE_BACKEND"
            ;;
    esac
}

function storage_dir_exists() {
    local target_path="$1"

    if [[ -z "${target_path}" ]]; then
	m_exit "storage_dir_exists: Missing arguments. Usage: storage_dir_exists <path>"
    fi

    case "${STORAGE_BACKEND,,}" in
        hdfs)
            # HDFS test will automatically inherit and return the exit code of this command (0 if it exists, 1 if it doesn't).
            "${HDFS_CMD[@]}" -test -d "${target_path}" 2>/dev/null
            return $?
            ;;
        nfs)
            # Remove 'file://' or 'file:' prefix if it exists in the input variable
            local clean_path="${target_path#file://}"
            clean_path="${clean_path#file:}"
            
            # Native POSIX test
            if [[ -d "${clean_path}" ]]; then
                return 0 # It exists
            else
                return 1 # It does not exist
            fi
            ;;
        *)
            m_exit "Storage backend not supported: $STORAGE_BACKEND"
            ;;
    esac
}

function storage_rm() {
    local recursive=""
    local target_path=""

    # Argument parsing
    if [[ "$1" == "-r" || "$1" == "-R" ]]; then
        recursive="-r"
        target_path="$2"
    else
        target_path="$1"
    fi

    # Checks
    if [[ -z "${target_path}" ]]; then
	m_exit "storage_rm: Missing arguments. Usage: storage_rm [-r|-R] <path>"
    fi

    case "${STORAGE_BACKEND,,}" in
        hdfs)
            # We leave the $recursive variable without quotes so that bash can evaluate whether to inject the flag or not inject anything (empty)
            "${HDFS_CMD[@]}" -rm $recursive -skipTrash "${target_path}" 2>/dev/null
            ;;
        nfs)
            # Remove 'file://' or 'file:' prefix if it exists in the input variable
            local clean_path="${target_path#file://}"
            clean_path="${clean_path#file:}"
            
            if [[ -z "${clean_path}" ]] || [[ "${clean_path}" == "/" ]] || [[ "${clean_path}" == "${NFS_MOUNT_POINT}" ]]; then
                m_exit "storage_rm: Blocked attempt to delete NFS root"
            fi
            
            if [ -n "$recursive" ]; then
                rm -rf "${clean_path}"
            else
                rm -f "${clean_path}"
            fi
            ;;
        *)
            m_exit "Storage backend not supported: $STORAGE_BACKEND"
            ;;
    esac
}

function storage_chmod() {
    local recursive=""
    local mode=""
    local target_path=""

    # Argument parsing
    if [[ "$1" == "-r" || "$1" == "-R" ]]; then
        recursive="-R"   
        mode="$2"
        target_path="$3"
    else
        mode="$1"
        target_path="$2"
    fi

    # Checks
    if [[ -z "${mode}" ]] || [[ -z "${target_path}" ]]; then
        m_exit "storage_chmod: Missing arguments. Usage: storage_chmod [-r|-R] <mode> <path>"
    fi

    case "${STORAGE_BACKEND,,}" in
        hdfs)
            "${HDFS_CMD[@]}" -chmod $recursive "${mode}" "${target_path}"
            ;;
        nfs)
            # Remove 'file://' or 'file:' prefix if it exists in the input variable
            local clean_path="${target_path#file://}"
            clean_path="${clean_path#file:}"
            
            if [ -n "$recursive" ]; then
                chmod -R "${mode}" "${clean_path}"
            else
                chmod "${mode}" "${clean_path}"
            fi
            ;;
        *)
            m_exit "Storage backend not supported: $STORAGE_BACKEND"
            ;;
    esac
}
