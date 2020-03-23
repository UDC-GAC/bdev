#!/bin/sh

## Configuration parameters for BDEv

export ENABLE_PLOT=false	# Enable plot generation
export ENABLE_STAT=false	# Enable built-in resource monitoring using dstat
export ENABLE_ILO=false		# Enable HPE iLO power monitoring
export ENABLE_RAPL=false	# Enable RAPL power monitoring
export ENABLE_OPROFILE=false	# Enable Oprofile event counting
export ENABLE_BDWATCHDOGfalse	# Enable resource monitoring through BDWatchdog
export DEFAULT_TIMEOUT=86400	# Default workload timeout
export OUT_DIR=$PWD/${METHOD_NAME}_OUT	# Default report output directory

# Resource stats
export STAT_GEN_GRAPHS=false	# Generate graphs during execution
export STAT_SECONDS_INTERVAL=5	# Interval (seconds) for each sample
export STAT_WAIT_SECONDS=20	# Waiting time (seconds) before each benchmark execution

# HPE iLO
export ILO_SECONDS_INTERVAL=5		# Interval (seconds) for each sample
export ILO_WAIT_SECONDS=20		# Waiting time (seconds) before each benchmark execution
export ILO_USERNAME="ilo_user"		# User name for ILO interface
export ILO_PASSWD="..ilo_user.."	# Password for ILO user
export ILO_BASE_IP=192.168.255		# Base IP for ILO interfaces
export ILO_MASTER=localhost		# Node which can connect to the ILO interface for all the slaves (localhost means to use the master node)

# RAPL
export RAPL_GEN_GRAPHS=false	# Generate RAPL graphs during execution
export RAPL_SECONDS_INTERVAL=5	# Interval (seconds) for each sample
export RAPL_WAIT_SECONDS=20	# Waiting time (seconds) before each benchmark execution

# OPROFILE
export OPROFILE_BIN_DIR=`dirname "$(which ocount 2> /dev/null)"`	# Directory containing OProfile binaries
export OPROFILE_EVENTS="INST_RETIRED,LLC_MISSES,LLC_REFS"	# Events to record during OProfile analysis (can be consulted by using the ophelp command)
export OPROFILE_WAIT_SECONDS=20		# Waiting time (seconds) before each benchmark execution

# BDWATCHDOG
export BDWATCHDOG_ATOP=true		# Enable resource monitoring with atop
export BDWATCHDOG_TURBOSTAT=true	# Enable energy monitoring with turbostat
export BDWATCHDOG_NETHOGS=true		# Enable network monitoring with nethogs
export TURBOSTAT_BIN_DIR=`dirname "$(which turbostat 2> /dev/null)"`	# Directory containing turbostat binaries
export BDWATCHDOG_USERNAME=`echo $USER`	# User name that runs the experiments (useful for the BDWatchdog web interface)
export BDWATCHDOG_SECONDS_INTERVAL=5	# Interval (seconds) for each sample
export BDWATCHDOG_WAIT_SECONDS=20	# Waiting time (seconds) before each benchmark execution
export BDWATCHDOG_POST_ENDPOINT="http://hostname:8080/tsdb/api/put"	# OpenTSDB post endpoint
export BDWATCHDOG_TIMESTAMPING=true   # Enable time stamping service
export BDWATCHDOG_MONGODB_IP=localhost	# IP/hostname where MongoDB is running
export BDWATCHDOG_MONGODB_PORT=8080	# Port number where MongoDB is listening
export BDWATCHDOG_TESTS_POST_ENDPOINT="times/tests"		# MongoDB post endpoint for tests
export BDWATCHDOG_EXPERIMENTS_POST_ENDPOINT="times/experiments"	# MongoDB post endpoint for experiments
