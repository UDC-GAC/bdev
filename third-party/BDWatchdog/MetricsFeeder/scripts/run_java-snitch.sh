#!/usr/bin/env bash
export JAVA_SNITCH_POLLING_SECONDS=5 #Poll every 5 seconds
export JAVA_SNITCH_TIME_TO_DUMP_COUNTER_MAX=2 # Dump each 2 pollings (10 seconds)

tmux new -s "JAVA_SNITCH" "python3 src/java_hadoop_snitch/java_snitch.py"
