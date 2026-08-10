#!/bin/bash

HDFS_CMD=("${HADOOP_HOME}/bin/hdfs" "dfs")

function get_storage_uri_prefix() {
    case "${STORAGE_BACKEND,,}" in
        hdfs)
            echo "hdfs://$MASTERNODE:$HDFS_PORT"
            ;;
        nfs)
            echo "file://${NFS_MOUNT_POINT}"
            ;;
        *)
            m_exit "Storage backend not supported: STORAGE_BACKEND"
            ;;
    esac
}

function storage_mkdir() {
    local target_dir=$1
    case "${STORAGE_BACKEND,,}" in
        hdfs)
           "${HDFS_CMD[@]}" -mkdir -p "${target_dir}"
            ;;
        nfs)
            mkdir -p "${NFS_MOUNT_POINT}/${target_dir}"
            ;;
        *)
            m_exit "Storage backend not supported: STORAGE_BACKEND"
            ;;
    esac
}

function storage_copy_from_local() {
    local local_file=$1
    local target_dir=$2
    case "${STORAGE_BACKEND,,}" in
        hdfs)
            "${HDFS_CMD[@]}" -put "${local_file}" "${target_dir}"
            ;;
        nfs)
            cp "${local_file}" "${NFS_MOUNT_POINT}/${target_dir}"
            ;;
        *)
            m_exit "Storage backend not supported: STORAGE_BACKEND"
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

    # Check
    if [ -z "${target_path}" ]; then
        m_exit "storage_rm: A valid path has not been specified"
        exit 1
    fi

    case "${STORAGE_BACKEND,,}" in
        hdfs)
            # We leave the $recursive variable without quotes so that bash can evaluate whether to inject the flag or not inject anything (empty)
            "${HDFS_CMD[@]}" -rm $recursive -skipTrash "${target_path}" 2>/dev/null
            ;;
        nfs)
            if [ "${target_path}" == "/" ] || [ "${target_path}" == "${BDEV_NFS_MOUNT_POINT}" ]; then
                m_exit "storage_rm: Blocked attempt to delete NFS root"
                exit 1
            fi
            
            if [ -n "$recursive" ]; then
                rm -rf "${BDEV_NFS_MOUNT_POINT}/${target_path}"
            else
                rm -f "${BDEV_NFS_MOUNT_POINT}/${target_path}"
            fi
            ;;
        *)
            m_exit "Storage backend not supported: STORAGE_BACKEND"
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

    if [ -z "${mode}" ] || [ -z "${target_path}" ]; then
        m_exit "storage_chmod: Missing arguments. Usage: storage_chmod [-R] <mode> <path>"
        exit 1
    fi

    case "${STORAGE_BACKEND,,}" in
        hdfs)
            "${HDFS_CMD[@]}" -chmod $recursive "${mode}" "${target_path}"
            ;;
        nfs)
            if [ -n "$recursive" ]; then
                chmod -R "${mode}" "${BDEV_NFS_MOUNT_POINT}/${target_path}"
            else
                chmod "${mode}" "${BDEV_NFS_MOUNT_POINT}/${target_path}"
            fi
            ;;
        *)
            m_exit "Storage backend not supported: STORAGE_BACKEND"
            ;;
    esac
}
