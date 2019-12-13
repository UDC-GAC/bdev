which hadoop > /dev/null
status=$?
if test $status -ne 0 ; then
	echo ""
	echo "Hadoop is not installed in the system."
	echo "Please install Hadoop and make sure the hadoop binary is accessible."
	exit 127
fi


hadoop dfs -rmr hadi_edge
hadoop dfs -mkdir hadi_edge
hadoop dfs -put catepillar_star.edge hadi_edge
./run_hadiblk.sh 16 3 hadi_edge makesym 2 noenc

