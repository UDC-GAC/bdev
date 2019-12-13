#!/usr/bin/env bash

usage() { echo "Usage: $0 -h host [-s start time] [-e end time] [-m metrics] [-w size]" 1>&2; exit 1; }

while getopts ":s:e:m:w:h:" o; do
    case "${o}" in
        h)
            h=${OPTARG}
            ;;
        s)
            s=${OPTARG}
            ;;
        e)
            e=${OPTARG}
            ;;
        m)
            m=${OPTARG}
            ;;           
        w)
            w=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${h}" ]; then
    usage
fi

TIMESTAMP_NOW=`date '+%s'`
TEN_MINUTES="600"
TIMESTAMP_10minutes_ago=$((TIMESTAMP_NOW-TEN_MINUTES))

HOST="${h}"
START="${s:-$TIMESTAMP_10minutes_ago}"
END="${e:-$TIMESTAMP_NOW}"

DATE_END=`date --date @${END} +"%Y/%m/%d-%H:%M:%S"`
DATE_START=`date --date @${START} +"%Y/%m/%d-%H:%M:%S"`


METRICS="${m:-cpu}"
SIZE="${w:-1700x500}"
METRICS_LABEL="$METRICS"

case "$METRICS" in
        cpu)
            METRICS="m=sum:sys.cpu.user%7Bhost=${HOST}%7D&m=sum:sys.cpu.kernel%7Bhost=${HOST}%7D&m=sum:sys.cpu.idle%7Bhost=${HOST}%7D&m=sum:sys.cpu.wait%7Bhost=${HOST}%7D"
            ;;
        CPU)
            METRICS="m=sum:sys.cpu.usage%7Bhost=${HOST}%7D"
            ;;
        MEM)
            METRICS="m=sum:proc.mem.resident%7Bhost=${HOST}%7D&m=sum:sys.mem.free%7Bhost=${HOST}%7D&m=sum:sys.swap.free%7Bhost=${HOST}%7D"
            ;;
        NET)
            METRICS="m=sum:sys.net.in.mb%7Bhost=${HOST}%7D&m=sum:sys.net.out.mb%7Bhost=${HOST}%7D"
            ;;
        DISK)
            METRICS="m=sum:sys.disk.write.mb%7Bhost=${HOST}%7D&m=sum:sys.disk.read.mb%7Bhost=${HOST}%7D"
            ;;
        usages)
            METRICS="m=sum:sys.cpu.usage%7Bhost=${HOST}%7D&m=sum:sys.mem.usage%7Bhost=${HOST}%7D&m=sum:sys.disk.usage%7Bhost=${HOST}%7D&m=sum:sys.net.usage%7Bhost=${HOST}%7D"
            ;;
        temp)
            METRICS="m=sum:sys.processors.temp%7Bhost=${HOST}%7D&m=avg:sys.cpu.temp%7Bhost=${HOST}%7Dm=avg:sys.core.temp%7Bhost=${HOST}%7D"
            ;;
        power)
            METRICS="m=sum:sys.processors.energy%7Bhost=${HOST}%7D&m=sum:sys.cpu.energy%7Bhost=${HOST}%7D"
            ;;            
        *)
            METRICS="m=sum:sys.cpu.user%7Bhost=${HOST}%7D&m=sum:sys.cpu.kernel%7Bhost=${HOST}%7D&m=sum:sys.cpu.idle%7Bhost=${HOST}%7D&m=sum:sys.cpu.wait%7Bhost=${HOST}%7D"
esac

QUERY_STRING="start=$START&end=$END&$METRICS&wxh=$SIZE&style=linespoint&png"
#echo "Going to query : " 
#echo $QUERY_STRING

echo "Drawing metrics for host $HOST from $START ($DATE_START) to $END ($DATE_END)"


curl -X GET http://opentsdb:4242/q?$QUERY_STRING 2>/dev/null > plotted_timeseries/${HOST}_${METRICS_LABEL}_${START}_to_${END}.png
