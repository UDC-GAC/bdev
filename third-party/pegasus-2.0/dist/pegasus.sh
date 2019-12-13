#!/bin/bash
# Interactive command line shell for PEGASUS

demo=0

function Pause()
{
	key=""
	echo -n Hit any key to continue....
	stty -icanon
	key=`dd count=1 2>/dev/null`
	stty icanon
}

function PrintIntro()
{
	echo ""
	echo "        PEGASUS: Peta-Scale Graph Mining System"
	echo "        Version 2.0"
	echo "        Last modified September 5th 2010"
	echo ""
	echo "        Authors: U Kang, Duen Horng Chau, and Christos Faloutsos"
	echo "                 School of Computer Science, Carnegie Mellon University"
	echo "        Distributed under APL 2.0 (http://www.apache.org/licenses/LICENSE-2.0)"
	echo ""
	echo "        Type \`help\` for available commands."
	echo "        The PEGASUS user manual is available at http://www.cs.cmu.edu/~pegasus"
	echo "        Send comments and help requests to <ukang@cs.cmu.edu>."
	echo ""
	echo ""
}

function PrintHelp()
{
	echo ""
	echo "        add [file or directory] [graph_name]"
	echo "            upload a local graph file or directory to HDFS"
	echo "        del [graph_name]"
	echo "            delete a graph"
	echo "        list"
	echo "            list graphs"
	echo "        compute ['deg' or 'pagerank' or 'rwr' or 'radius' or 'cc'] [graph_name]"
	echo "            run an algorithm on a graph"
	echo "        plot ['deg' or 'pagerank' or 'rwr' or 'radius' or 'cc' or 'corr'] [graph_name]"
	echo "            generate plots"
	echo "        exit"
	echo "            exit PEGASUS"
	echo "        help"
	echo "            show this screen"
	echo ""
}

function Demo()
{
	Add "catepillar_star.edge catstar"
	Run "deg catstar demo"	
}

function CreateHDir {
	cur_path=""

	for args in "$@"
	do
		if [ ${#cur_path} -eq 0 ]; then
		    cur_path=$args
		else
		    cur_path=$cur_path/$args
		fi
		hadoop fs -ls $cur_path > /dev/null 2>&1
		if [ $? -ne 0 ]; then
			echo "Creating $cur_path in HDFS"
			hadoop fs -mkdir $cur_path
		fi
	done	
}

function CreateGraphDir {
	hadoop fs -ls pegasus > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "Creating pegasus in HDFS"
		hadoop fs -mkdir pegasus
	fi
	hadoop fs -ls pegasus/graphs > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "Creating pegasus/graphs in HDFS"
		hadoop fs -mkdir pegasus/graphs
	fi
	hadoop fs -ls pegasus/graphs/$1 > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "Creating pegasus/graphs/$1 in HDFS"
		hadoop fs -mkdir pegasus/graphs/$1
	fi
	hadoop fs -ls pegasus/graphs/$1/edge > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "Creating pegasus/graphs/$1/edge in HDFS"
		hadoop fs -mkdir pegasus/graphs/$1/edge
	fi
}

function Add {
	set -- $1
	if [ $# -lt 2 ]; then
		echo "        Invalid syntax."
		echo "        add [file or directory] [graph_name]"
		echo ""
		return
	fi

	CreateGraphDir $2

	if [ -f $1 ]; then
		hadoop fs -put $1 pegasus/graphs/$2/edge
		echo "Graph $2 added."
	elif [ -d $1 ]; then
		hadoop fs -put $1/* pegasus/graphs/$2/edge
		echo "Graph $2 added."
	else
		echo "Error: $1 is not a regular file or directory."
	fi
}

function Del {
	set -- $1
	if [ $# -ne 1 ]; then
		echo "        Invalid syntax."
		echo "        del [graph_name]"
		echo ""
		return
	fi

	hadoop fs -rmr pegasus/graphs/$1 > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "Error: can't remove graph $1. Check whether it exists."
	else
		echo "Graph $1 deleted."
	fi
}

function List {
	echo -e "=== GRAPH LIST === \n"
	hadoop fs -ls pegasus/graphs | grep "^d" | awk '{print $8}' | awk -F"/" '{ print $NF}'
	echo ""
}


function Run {
	set -- $1
	if [ $# -lt 2 ]; then
		echo "        Invalid syntax."
		echo "        compute ['deg' or 'pagerank' or 'rwr' or 'radius' or 'cc'] [graph_name]"
		echo ""
		return
	fi
	in_graph=$2

	case "$1" in
	deg) if [ $# -eq 2 ]; then
 		echo -n "Enter parameters: [in or out or inout] [#_of_reducers]: "
		read deg_type nreducers
	    else
		deg_type=inout
		nreducers=1
	    fi
	    ./run_dd.sh $deg_type $nreducers pegasus/graphs/$in_graph/edge

	    hadoop fs -rmr pegasus/graphs/$in_graph/results/deg/$deg_type/*
	    CreateHDir pegasus graphs $in_graph results deg $deg_type
	    hadoop fs -mv dd_node_deg pegasus/graphs/$in_graph/results/deg/$deg_type/dd_node_deg
	    hadoop fs -mv dd_deg_count pegasus/graphs/$in_graph/results/deg/$deg_type/dd_deg_count

	    if [ $# -eq 3 ]; then
		MineDeg catstar inout
	    fi
	    continue
	    ;;
	pagerank) echo -n "Enter parameters: [#_of_nodes] [#_of_reducers] [makesym or nosym]: "
	    read n_nodes n_reducers sym_type
	    ./run_pr.sh $n_nodes $n_reducers pegasus/graphs/$in_graph/edge $sym_type

	    hadoop fs -rmr pegasus/graphs/$in_graph/results/pagerank/*
	    CreateHDir pegasus graphs $in_graph results pagerank
	    hadoop fs -mv pr_vector pegasus/graphs/$in_graph/results/pagerank/pr_vector
	    hadoop fs -mv pr_minmax pegasus/graphs/$in_graph/results/pagerank/pr_minmax
	    hadoop fs -mv pr_distr pegasus/graphs/$in_graph/results/pagerank/pr_distr
	    continue
	    ;;
	rwr) echo -n "Enter parameters: [query_path] [#_of_nodes] [#_of_reducers] [makesym or nosym]: "
	    read query_path n_nodes n_reducers sym_type
	    ./run_rwr.sh pegasus/graphs/$in_graph/edge $query_path $n_nodes $n_reducers $sym_type new 0.85

	    hadoop fs -rmr pegasus/graphs/$in_graph/results/rwr/*
	    CreateHDir pegasus graphs $in_graph results rwr
	    hadoop fs -mv rwr_vector pegasus/graphs/$in_graph/results/rwr/rwr_vector
	    hadoop fs -mv rwr_minmax pegasus/graphs/$in_graph/results/rwr/rwr_minmax
	    hadoop fs -mv rwr_distr pegasus/graphs/$in_graph/results/rwr/rwr_distr
	    continue
	    ;;
	radius) echo -n "Enter parameters: [#_of_nodes] [#_of_reducers] [makesym or nosym]: "
	    read n_nodes n_reducers sym_type
	    ./run_hadi.sh $n_nodes $n_reducers pegasus/graphs/$in_graph/edge $sym_type enc

	    hadoop fs -rmr pegasus/graphs/$in_graph/results/radius/*
	    CreateHDir pegasus graphs $in_graph results radius
	    hadoop fs -mv hadi_radius pegasus/graphs/$in_graph/results/radius/hadi_radius
	    hadoop fs -mv hadi_radius_summary pegasus/graphs/$in_graph/results/radius/radius_distr
	    continue
	    ;;
	cc)  echo -n "Enter parameters: [#_of_nodes] [#_of_reducers]: "
	    read n_nodes n_reducers
	    ./run_ccmpt.sh $n_nodes $n_reducers pegasus/graphs/$in_graph/edge

	    hadoop fs -rmr pegasus/graphs/$in_graph/results/cc/*
	    CreateHDir pegasus graphs $in_graph results cc
	    hadoop fs -mv concmpt_curbm pegasus/graphs/$in_graph/results/cc/concmpt_curbm
	    hadoop fs -mv concmpt_summaryout pegasus/graphs/$in_graph/results/cc/concmpt_summaryout
	    hadoop fs -cat pegasus/graphs/$in_graph/results/cc/concmpt_summaryout/* | cut -f 2 | sort -n | ./uniq.py > pegasus_cc_distr.tab
	    CreateHDir pegasus graphs $in_graph results cc concmpt_distr
	    hadoop fs -put pegasus_cc_distr.tab pegasus/graphs/$in_graph/results/cc/concmpt_distr
	    rm -rf pegasus_cc_distr.tab
	    continue
	    ;;
	exit)
	    break
	    ;;
	*) echo "Invalid algorithm. Use 'deg' or 'pagerank' or 'rwr' or 'radius' or 'cc'."
	    return
	    ;;
	esac
}

function MineDeg {
	in_graph=$1
	deg_type=$2

	temp_filename=pegasus_deg_$1_$2
	hadoop fs -cat pegasus/graphs/$in_graph/results/deg/$deg_type/dd_deg_count/* > $temp_filename
	cp pegasus_deg_template.plt pegasus_deg.plt
	echo "set output \"$1_deg_$2.eps\"" >> pegasus_deg.plt
	echo "set xlabel \"$2 degree\"" >> pegasus_deg.plt
	echo "plot \"$temp_filename\" using 1:2 title \"$1\" lt 1 pt 1 ps 2 lc 3 lw 4" >> pegasus_deg.plt
	gnuplot pegasus_deg.plt > /dev/null 2>& 1

	if [ $? -ne 0 ]; then
		echo "Error: can't mine $2 degree of the graph $1. Check whether the $2 degree is computed, or gnuplot is installed correctly."
	else
		echo "$2-degree distribution plotted in \"$1_deg_$2.eps\"."
	fi

	rm -f $temp_filename
	rm -f pegasus_deg.plt
}

function MinePagerank {
	in_graph=$1
	alg="pagerank"
	temp_filename=pegasus_distr_$1
	output_filename=$1_pagerank.eps

	hadoop fs -cat pegasus/graphs/$in_graph/results/pagerank/pr_distr/* > $temp_filename
	cp pegasus_distr_template.plt pegasus_distr.plt
	echo "set output \"$output_filename\"" >> pegasus_distr.plt
	echo "set xlabel \"$alg\"" >> pegasus_distr.plt
	echo "plot \"$temp_filename\" using 1:2 title \"$1\" lt 1 pt 1 ps 2 lc 3 lw 4" >> pegasus_distr.plt
	gnuplot pegasus_distr.plt > /dev/null 2>& 1

	if [ $? -ne 0 ]; then
		echo "Error: can't mine $alg of the graph $1. Check whether the $alg of $in_graph is computed, or gnuplot is installed correctly."
	else
		echo "$alg distribution plotted in \"$output_filename\"."
	fi

	rm -f $temp_filename
	rm -f pegasus_distr.plt
}

function MineAlg {
	in_graph=$1
	alg=$2
	distr_path=$3
	plot_template=$4

	temp_filename=pegasus_distr_$1
	output_filename=$1_$alg.eps

	hadoop fs -cat pegasus/graphs/$in_graph/results/$distr_path/* > $temp_filename
	cp $plot_template pegasus_distr.plt
	echo "set output \"$output_filename\"" >> pegasus_distr.plt
	echo "set xlabel \"$alg\"" >> pegasus_distr.plt
	echo "plot \"$temp_filename\" using 1:2 title \"$1\" lt 1 pt 1 ps 2 lc 3 lw 4" >> pegasus_distr.plt
	gnuplot pegasus_distr.plt > /dev/null 2>& 1

	if [ $? -ne 0 ]; then
		echo "Error: can't mine $alg of the graph $1. Check whether the $alg of $in_graph is computed, or gnuplot is installed correctly."
	else
		echo "$alg distribution plotted in \"$output_filename\"."
	fi

	rm -f $temp_filename
	rm -f pegasus_distr.plt
}

function MineCorr {
	ingraph=$1
	n_reducers=$2

	echo ingraph=$ingraph, reducers=$n_reducers

	# check whether the results for deg, pagerank, and radius exist.
	hadoop fs -ls pegasus/graphs/$ingraph/results/deg/inout/dd_node_deg > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "Error: compute the inout degree first."
		return
	fi
	hadoop fs -ls pegasus/graphs/$ingraph/results/pagerank/pr_vector > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "Error: compute the pagerank first."
		return
	fi
	hadoop fs -ls pegasus/graphs/$ingraph/results/radius/hadi_radius > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "Error: compute the radius first."
		return
	fi

	# join table
	./run_jointable_pegasus.sh $n_reducers SemiJoin pegasus/graphs/$ingraph/results/corr pegasus/graphs/$ingraph/results/deg/inout/dd_node_deg pegasus/graphs/$ingraph/results/pagerank/pr_vector pegasus/graphs/$ingraph/results/radius/hadi_radius

	# generate plots
	data_filename=pegasus_corr_$1
	hadoop fs -cat pegasus/graphs/$ingraph/results/corr/* > $data_filename

	# PageRank-degree
	output_filename="$ingraph"_pagerank_deg.eps
	cp -f pegasus_corr_pagerank_deg_template.plt pegasus_corr.plt
	echo "set output \"$output_filename\"" >> pegasus_corr.plt
	echo "plot \"$data_filename\" using 2:3 title \"$1\" lt 1 pt 1 ps 2 lc 3 lw 4" >> pegasus_corr.plt
	gnuplot pegasus_corr.plt > /dev/null 2>& 1

	if [ $? -ne 0 ]; then
		echo "Error: can't plot degree-pagerank of the graph $1. Check whether the degree and pagerank of $ingraph is computed, or gnuplot is installed correctly."
		return
	else
		echo "degree-pagerank is plotted in \"$output_filename\"."
	fi


	# degree-radius
	output_filename="$ingraph"_deg_radius.eps
	cp -f pegasus_corr_deg_radius_template.plt pegasus_corr.plt
	echo "set output \"$output_filename\"" >> pegasus_corr.plt
	echo "plot \"$data_filename\" using 4:2 title \"$1\" lt 1 pt 1 ps 2 lc 3 lw 4" >> pegasus_corr.plt
	gnuplot pegasus_corr.plt > /dev/null 2>& 1

	if [ $? -ne 0 ]; then
		echo "Error: can't plot radius-degree of the graph $1. Check whether the radius and degree of $ingraph is computed, or gnuplot is installed correctly."
		return
	else
		echo "radius-degree is plotted in \"$output_filename\"."
	fi


	# PageRank-radius
	output_filename="$ingraph"_pagerank_radius.eps
	cp -f pegasus_corr_pagerank_radius_template.plt pegasus_corr.plt
	echo "set output \"$output_filename\"" >> pegasus_corr.plt
	echo "plot \"$data_filename\" using 4:3 title \"$1\" lt 1 pt 1 ps 2 lc 3 lw 4" >> pegasus_corr.plt
	gnuplot pegasus_corr.plt > /dev/null 2>& 1

	if [ $? -ne 0 ]; then
		echo "Error: can't plot radius-PageRank of the graph $1. Check whether the radius and PageRank of $ingraph is computed, or gnuplot is installed correctly."
		return
	else
		echo "radius-PageRank is plotted in \"$output_filename\"."
	fi

	rm -f $data_filename
	rm -f pegasus_corr.plt
}

function Mine {
	set -- $1
	if [ $# -ne 2 ]; then
		echo "        Invalid syntax."
		echo "        plot ['deg' or 'pagerank' or 'rwr' or 'radius' or 'cc' or 'corr'] [graph_name]"
		echo ""
		return
	fi
	in_graph=$2

	case "$1" in
	deg) echo -n "Enter parameters: [in or out or inout]: "
	    read deg_type
	    MineDeg $in_graph $deg_type
	    continue
	    ;;
	pagerank) MineAlg $in_graph pagerank pagerank/pr_distr pegasus_distr_template.plt
	    continue
	    ;;
	rwr) MineAlg $in_graph rwr rwr/rwr_distr pegasus_distr_template.plt
	    continue
	    ;;
	radius) MineAlg $in_graph radius radius/radius_distr pegasus_radius_template.plt
	    continue
	    ;;
	cc) MineAlg $in_graph cc cc/concmpt_distr pegasus_distr_template.plt
	    continue
	    ;;
	corr) echo -n "Enter parameters: [#_of_reducers]: "
	    read n_reducers
	    MineCorr $in_graph $n_reducers
	    continue
	    ;;
	exit)
	    break
	    ;;
	*) echo "Invalid algorithm. Use 'deg' or 'pagerank' or 'rwr' or 'radius' or 'cc'."
	    return
	    ;;
	esac
}


##################################################
##### Main Function
##################################################

PrintIntro

while [ 1 -eq 1 ]; do
	echo -n "PEGASUS> "
	read CMD REST
	case "$CMD" in
	"") continue
	    ;;
	help) PrintHelp
	    continue
	    ;;
	demo) Demo
	    continue
	    ;;
	add) Add "$REST"
	    continue
	    ;;
	del) Del "$REST"
	    continue
	    ;;
	list) List
	    continue
	    ;;
	compute) Run "$REST"
	    continue
	    ;;
	plot) Mine "$REST"
	    continue
	    ;;
	exit)
	    break
	    ;;
	*) echo "Invalid command. Type \`help\` for available commands."
	    ;;
	esac
done


