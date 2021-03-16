package es.udc.gac.sparkbench.rdd

import org.apache.spark.{ SparkConf, SparkContext }
import org.apache.spark.rdd._
import es.udc.gac.sparkbench.IOCommon

/*
 * Adapted from spark's example: https://spark.apache.org/examples.html
 */
object ScalaWordCount {

  def main(args: Array[String]) {

    if (args.length < 2) {
      System.err.println("Usage: ScalaWordCount <INPUT_PATH> <OUTPUT_PATH> [ Sequence | KeyValueText ]")
      System.exit(1)
    }

    val conf = new SparkConf().setAppName("SparkBench ScalaWordCount")
    val sc = new SparkContext(conf)
    val filename = args(0)
    val save_file = args(1)
    
    var format = "Sequence"
    if (args.length > 2)
      format = args(2)
    
    val io = new IOCommon()
    val lines = io.load(filename, sc, format)
    val words = lines.flatMap( { case (key, line) => line.split(" |\t") } )
    val words_map = words.map(word => (word, 1))
    val result = words_map.reduceByKey(_ + _)

    io.save[String,Int](save_file, result, sc, format)
    //sc.stop()
  }
}
