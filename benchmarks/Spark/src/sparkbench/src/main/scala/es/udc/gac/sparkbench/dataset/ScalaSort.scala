package es.udc.gac.sparkbench.dataset

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark._
import org.apache.spark.rdd._
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions._
import es.udc.gac.sparkbench.IOCommon

object ScalaSort {

  def main(args: Array[String]) {

    if (args.length < 2) {
      System.err.println("Usage: ScalaSort <INPUT_PATH> <OUTPUT_PATH> [ Sequence | KeyValueText ]")
      System.exit(1)
    }

    val session = SparkSession.builder().appName("SparkBench ScalaSort").getOrCreate()
    import session.implicits._

    val filename = args(0)
    val save_file = args(1)

    var format = "Sequence"
    if (args.length > 2)
      format = args(2)

    val io = new IOCommon()
    val data = io.load_dataset(filename, session, format)

    val sorted = data
      .repartition(
        session.sparkContext.getConf.getInt(
          "spark.default.parallelism", 
          session.sparkContext.defaultParallelism), 
        $"value")
      .sortWithinPartitions("value");

    io.save_dataset(save_file, sorted, session, format)
    //sc.stop()
  }
}
