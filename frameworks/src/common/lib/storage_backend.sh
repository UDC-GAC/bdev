#!/bin/bash

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
            hdfs dfs -mkdir -p "${target_dir}"
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
            hdfs dfs -put "${local_file}" "${target_dir}"
            ;;
        nfs)
            cp "${local_file}" "${NFS_MOUNT_POINT}/${target_dir}"
            ;;
        *)
            m_exit "Storage backend not supported: STORAGE_BACKEND"
            ;;
    esac
}
