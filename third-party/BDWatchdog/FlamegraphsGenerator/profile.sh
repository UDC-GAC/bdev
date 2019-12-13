mkdir -p out
mkdir -p recording

hash perf 2>/dev/null || { echo >&2 "I require foo but it's not installed.  Aborting."; exit 1; }

perf record  -a -- sleep 1 1>/dev/null 2>/dev/null
if [ $? -eq 0 ]; then
    echo ""
else
    echo "perf couldn't execute due to permission failures, run the allow_perf.sh script and try again or run perf record manually and check for errors"
    exit 1;
fi



TIME_WINDOW_SECONDS="${1:-30}"
PROFILING_FREQUENCY="${2:-153}"
echo "[PERF PROFILER] Going to profile with a '$TIME_WINDOW_SECONDS' seconds time window and with '$PROFILING_FREQUENCY' HZ frequency"
while true
do
  out_file_name=`date +%s`.data
  perf record -F $PROFILING_FREQUENCY -a -g -o recording/$out_file_name 2>/dev/null -- sleep $TIME_WINDOW_SECONDS
  mv recording/$out_file_name out
  echo "Profiled correctly at " `date`
done

