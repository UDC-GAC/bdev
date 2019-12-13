which hadoop > /dev/null
status=$?
if test $status -ne 0 ; then
	echo ""
	echo "Hadoop is not installed in the system."
	echo "Please install Hadoop and make sure the hadoop binary is accessible."
	exit 127
fi

hadoop dfs -rmr dd_edge
hadoop dfs -mkdir dd_edge
hadoop dfs -put catepillar_star.edge dd_edge
./run_dd.sh inout 16 dd_edge
