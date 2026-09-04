#!/bin/bash

## Global configuration parameters

export STORAGE_BACKEND=hdfs	# Supported backends: hdfs, nfs
export NFS_MOUNT_POINT=${NFS_MOUNT_POINT:-""}	# Only required if STORAGE_BACKEND=nfs
export ENABLE_HOSTNAMES=true	# When set to false, BDEv use IPs instead of hostnames for cluster nodes
export DEFAULT_TIMEOUT=3600	# Default workload timeout (in seconds)
export ENABLE_RUNTIME_PLOTS=false	# Generates performance plots with the execution time of workloads
export ENABLE_MODULES=false	# Enable use of environment modules & Lmod
export MODULES_JAVA="java"	# Modules to load for enabling Java
export MODULES_PYTHON="python"	# Modules to load for enabling Python
export DISK_SPACE_THRESHOLD=10	# Free disk space percentage required before triggering a low-space warning

# Monitoring
export ENABLE_STAT=false	# Enable built-in resource monitoring using dool
export ENABLE_RAPL=false	# Enable RAPL power monitoring
export ENABLE_OPROFILE=false	# Enable Oprofile event counting
export ENABLE_ILO=false		# Enable HPE iLO power monitoring
export ENABLE_BDWATCHDOG=false	# Enable resource monitoring using BDWatchdog
export MONITOR_DELAY_SECONDS=10	# Delay time (seconds) after/before starting/stopping all monitors

# Resource stats
export STAT_GEN_PLOTS=false	# Generate plots for all nodes during execution
export STAT_SECONDS_INTERVAL=2	# Interval (seconds) for each sample

# RAPL
export RAPL_GEN_PLOTS=false	# Generate plots for all nodes during execution
export RAPL_SECONDS_INTERVAL=2	# Interval (seconds) for each sample

# OPROFILE
export OPROFILE_BIN="ocount"	# OProfile command
export OPROFILE_EVENTS="inst_retired"	# Comma-separared list of events that will be logged. Supported events scan be queried using the ophelp command

# HPE iLO
export ILO_SECONDS_INTERVAL=2		# Interval (seconds) for each sample
export ILO_USERNAME="ilo_user"		# User name for ILO interface
export ILO_PASSWD="..ilo_user.."	# Password for ILO user
export ILO_BASE_IP=192.168.255		# Base IP for ILO interfaces
export ILO_MASTER=localhost		# Node which can connect to the ILO interface for all the workers (localhost means to use the master node)

# BDWATCHDOG
export BDWATCHDOG_ATOP=true		# Enable resource monitoring with atop
export BDWATCHDOG_TURBOSTAT=true	# Enable power monitoring with turbostat
export BDWATCHDOG_NETHOGS=true		# Enable network monitoring with nethogs
export TURBOSTAT_BIN="turbostat"	# Turbostat command for power monitoring
export BDWATCHDOG_USERNAME="$USER"	# User name that runs the experiments (useful for the BDWatchdog web interface)
export BDWATCHDOG_SECONDS_INTERVAL=2	# Interval (seconds) for each sample
export BDWATCHDOG_POST_ENDPOINT="http://hostname:8080/tsdb/api/put"	# OpenTSDB post endpoint
export BDWATCHDOG_TIMESTAMPING=true	# Enable time stamping service
export BDWATCHDOG_MONGODB_IP=localhost	# IP/hostname where MongoDB is running
export BDWATCHDOG_MONGODB_PORT=8080	# Port number where MongoDB is listening
export BDWATCHDOG_TESTS_POST_ENDPOINT="times/tests"		# MongoDB post endpoint for tests
export BDWATCHDOG_EXPERIMENTS_POST_ENDPOINT="times/experiments"	# MongoDB post endpoint for experiments
