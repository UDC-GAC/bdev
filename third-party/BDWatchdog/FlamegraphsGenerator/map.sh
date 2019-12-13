TIME_WINDOW_SECONDS="${1:-10}"
echo "[JAVA PERF AGENT MAPPER] Going to map with a '$TIME_WINDOW_SECONDS' seconds time window"
while true
do
	sudo ./FlameGraph/jmaps
	sleep $TIME_WINDOW_SECONDS
done


