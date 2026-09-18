#!/bin/bash

parallel_ssh "killall -u '$USER' -q -SIGINT '$OPROFILE_BIN'" "${OPROFILELOGDIR}/log" "Stopping oprofile monitor"
