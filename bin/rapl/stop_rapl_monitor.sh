#!/bin/bash

parallel_ssh "killall -u '$USER' -q -9 '$RAPL_COMMAND_NAME'" "${RAPLLOGDIR}/log" "Stopping rapl monitor"
