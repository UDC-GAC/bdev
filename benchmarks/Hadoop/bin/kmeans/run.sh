#!/bin/sh

storage_rm -R ${OUTPUT_KMEANS}

run_benchmark "${MAHOUT_HOME}/bin/mahout kmeans \
		-i ${INPUT_KMEANS}/samples -c ${INPUT_KMEANS}/cluster \
		-o ${OUTPUT_KMEANS} -x ${KMEANS_MAX_ITERATIONS} -ow -cl -cd ${KMEANS_CONVERGENCE_DELTA} \
		-dm org.apache.mahout.common.distance.EuclideanDistanceMeasure -xm mapreduce"
