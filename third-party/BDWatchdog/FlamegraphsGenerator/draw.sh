while getopts ":s:e:h:" o; do
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
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))


TIMESTAMP_NOW=`date '+%s'`
TEN_MINUTES="600"
TIMESTAMP_10minutes_ago=$((TIMESTAMP_NOW-TEN_MINUTES))

HOST="${h:-ALL}"
START="${s:-$TIMESTAMP_10minutes_ago}"
END="${e:-$TIMESTAMP_NOW}"

DATE_END=`date --date @${END} +"%Y/%m/%d-%H:%M:%S"`
DATE_START=`date --date @${START} +"%Y/%m/%d-%H:%M:%S"`


echo "Drawing flamegraphs from $START ($DATE_START) to $END ($DATE_END) for hostname $HOST"
rm  ./flamegraph.svg 2> /dev/null
python ./scripts/mongodb-to-jsons.py $START $END $HOST| ./scripts/jsons-to-stacks.py | ./FlameGraph/flamegraph.pl --color=java > flamegraph.svg
