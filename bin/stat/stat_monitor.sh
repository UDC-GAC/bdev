#!/bin/sh

${DSTAT} -T -c -C total --load -ms -d --disk-util -fn --output ${STATLOGFILE} --noheaders --noupdate ${STAT_SECONDS_INTERVAL}

