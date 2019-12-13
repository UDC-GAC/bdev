#!/usr/bin/env bash

usage() { echo "Usage: $0 -h host [-s start time] [-e end time] [-w size]" 1>&2; exit 1; }


while getopts ":s:e:w:h:" o; do
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

THIS_HOSTNAME=`hostname`
HOST="${h:-$THIS_HOSTNAME}"

START="${s:-$TIMESTAMP_10minutes_ago}"
END="${e:-$TIMESTAMP_NOW}"
SIZE="${w:-1700x500}"

echo "Drawing metrics for host $HOST from $START to $END"
mkdir -p plotted_timeseries
bash scripts/draw.sh -h ${HOST} -m usages -s $START -e $END -w $SIZE
bash scripts/draw.sh -h ${HOST} -m cpu -s $START -e $END -w $SIZE
bash scripts/draw.sh -h ${HOST} -m MEM -s $START -e $END -w $SIZE
bash scripts/draw.sh -h ${HOST} -m DISK -s $START -e $END -w $SIZE
bash scripts/draw.sh -h ${HOST} -m NET -s $START -e $END -w $SIZE
bash scripts/draw.sh -h ${HOST} -m power -s $START -e $END -w $SIZE
bash scripts/draw.sh -h ${HOST} -m temp -s $START -e $END -w $SIZE
 
