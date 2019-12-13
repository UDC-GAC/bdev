#!/usr/bin/env bash
export PYTHONUNBUFFERED="yes"
export POST_DOC_BUFFER_TIMEOUT=10

METRIC="CPU,cpu,MEM,SWP,DSK,NET,PRC,PRM,PRD"
#METRIC="PRC,PRM,PRD"

# Add PRN to support per-process network metrics using the netatop module if available

# If for any reason the module can't be used (e.g., containers of any sort are used), you
# can always use the nethogs script by installing it with the 'installation/install_nethgogs.sh' script
# and running it with the 'run_nethgogs.sh' script

# Uncomment this to run if netatop is used so that the module is loaded
# bash allow_netatop.sh


tmux new -s "ATOP" "atop 5 -a -P $METRIC | python3 ./src/atop/atop_to_json_with_java_translation.py | python3 ./src/pipelines/send_to_OpenTSDB.py"