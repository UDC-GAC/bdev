which hadoop > /dev/null
status=$?
if test $status -ne 0 ; then
	echo ""
	echo "Hadoop is not installed in the system."
	echo "Please install Hadoop and make sure the hadoop binary is accessible."
	exit 127
fi


hadoop dfs -rmr pr_edge
hadoop dfs -mkdir pr_edge
hadoop dfs -put catepillar_star.edge pr_edge
./run_pr.sh 16 5 pr_edge nosym

