# Program : run_mvprep.sh
# Description : Run MatvecPrep which preprocess normal edge files or vector files to block forms.
if [ $# -ne 7 ]; then
	 echo 1>&2 Usage: $0 [input HDFS path] [output HDFS path] [#_of_rows] [block size] [#_of_reducers] [out_prefix or null] [makesym or nosym]
	 echo 1>&2   Ex1: $0 ya_edge ya_blockedge 1413511390 32 100 null makesym
	 echo 1>&2   Ex2: $0 mv_edge mv_outedge 5 2 3 msc nosym
	 exit 127
fi

rm -rf $2

hadoop dfs -rmr $2

hadoop jar pegasus-2.0.jar pegasus.matvec.MatvecPrep $*
