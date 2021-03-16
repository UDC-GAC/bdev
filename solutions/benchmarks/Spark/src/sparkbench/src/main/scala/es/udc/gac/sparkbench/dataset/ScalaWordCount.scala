package es.udc.gac.sparkbench.dataset

import es.udc.gac.sparkbench.IOCommon
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions._
import org.apache.spark.{SparkConf, SparkContext}

/*
 * Adapted from spark's example: https://spark.apache.org/examples.html
 */
object ScalaWordCount {

  def main(args: Array[String]) {

    if (args.length < 2) {
      System.err.println("Usage: ScalaWordCount <INPUT_PATH> <OUTPUT_PATH> [ Sequence | KeyValueText ]")
      System.exit(1)
    }


    val session = SparkSession.builder().appName("SparkBench ScalaWordCount").getOrCreate()
    import session.implicits._
    val filename = args(0)
    val save_file = args(1)
    var format = "Sequence"
    if (args.length > 2)
      format = args(2)
    
    val io = new IOCommon()
    val lines = io.load_dataset(filename, session, format)
    val words = lines.flatMap( { line => line._2.split(" |\t") } )
    val words_grouped = words.groupBy($"value").agg(count("*").as("count")).as[(String, BigInt)]
    
    //val result = words_grouped.map( { case (word: String, count: BigInt) => word + "\t" + count.toString() } )

    io.save_dataset(save_file, words_grouped, session, format)
    //sc.stop()
  }
}
