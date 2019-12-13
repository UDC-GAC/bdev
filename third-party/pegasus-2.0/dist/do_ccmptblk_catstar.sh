which hadoop > /dev/null
status=$?
if test $status -ne 0 ; then
	echo ""
	echo "Hadoop is not installed in the system."
	echo "Please install Hadoop and make sure the hadoop binary is accessible."
	exit 127
fi


hadoop dfs -rmr cc_edge
hadoop dfs -mkdir cc_edge
hadoop dfs -put catepillar_star.edge cc_edge

./run_ccmptblk.sh 16 3 cc_edge 5
