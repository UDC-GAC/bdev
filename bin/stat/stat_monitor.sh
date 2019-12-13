#!/bin/sh

${DSTAT} -T -c -C total --load -ms -d --disk-util -fn --output ${STATLOGFILE} --nocolor ${STAT_SECONDS_INTERVAL}

