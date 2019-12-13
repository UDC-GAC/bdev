which hadoop > /dev/null
status=$?
if test $status -ne 0 ; then
	echo ""
	echo "Hadoop is not installed in the system."
	echo "Please install Hadoop and make sure the hadoop binary is accessible."
	exit 127
fi


hadoop dfs -rmr rwr_edge
hadoop dfs -mkdir rwr_edge
hadoop dfs -put catepillar_star.edge rwr_edge

hadoop dfs -rmr rwr_query
hadoop dfs -mkdir rwr_query
hadoop dfs -put catepillar_star_rwr.query rwr_query

./run_rwr.sh rwr_edge rwr_query 16 5 makesym new 0.85
