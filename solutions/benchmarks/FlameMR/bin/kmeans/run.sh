#!/bin/sh

FLAMEMRMAHOUT=${SOLUTION_DIR}/bin/flamemr_mahout

${HDFS_CMD} ${RMR} $OUTPUT_KMEANS

run_benchmark "${FLAMEMRMAHOUT} kmeans \
		-i ${INPUT_KMEANS}/samples -c ${INPUT_KMEANS}/cluster \
		-o ${OUTPUT_KMEANS} -x ${KMEANS_MAX_ITERATIONS} -ow -cl -cd ${KMEANS_CONVERGENCE_DELTA} \
		-dm org.apache.mahout.common.distance.EuclideanDistanceMeasure -xm mapreduce"

if [ $(cat $TMPLOGFILE | grep -i -E 'job failed|FinalApplicationStatus=FAILED|Exception in thread "main"' | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
