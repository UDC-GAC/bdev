package es.udc.gac.sparkbench.rdd

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark._
import org.apache.spark.rdd._
import org.apache.spark.sql.SparkSession
import es.udc.gac.sparkbench.IOCommon

object ScalaSort {

  def main(args: Array[String]) {

    if (args.length < 2) {
      System.err.println("Usage: ScalaSort <INPUT_PATH> <OUTPUT_PATH> [ Sequence | KeyValueText ]")
      System.exit(1)
    }

    val conf = new SparkConf().setAppName("SparkBench ScalaSort")
    val sc = new SparkContext(conf)
    val filename = args(0)
    val save_file = args(1)

    var format = "Sequence"
    if (args.length > 2)
      format = args(2)

    val parallel = sc.getConf.getInt("spark.default.parallelism", sc.defaultParallelism)
    val io = new IOCommon()


    val data = io.load(filename, sc, format)
    val partitioner = new HashPartitioner(parallel)
    val sorted = data.repartitionAndSortWithinPartitions(partitioner = partitioner)

    io.save[String, String](save_file, sorted, sc, format)
    //sc.stop()
  }
}
