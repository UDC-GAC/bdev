package es.udc.gac.sparkbench.rdd

import org.apache.spark.{ SparkConf, SparkContext }
import org.apache.spark._
import org.apache.spark.rdd._
import es.udc.gac.sparkbench.IOCommon

object ScalaGrep {

  def main(args: Array[String]) {

    if (args.length < 3) {
      System.err.println("Usage: ScalaGrep <INPUT_PATH> <OUTPUT_PATH> <REG_EX> [ Sequence | KeyValueText ]")
      System.exit(1)
    }

    val conf = new SparkConf().setAppName("SparkBench ScalaGrep")
    val sc = new SparkContext(conf)
    val filename = args(0)
    val save_file = args(1)
    val regex = args(2).r
    
    var format = "Sequence"
    if (args.length > 3)
      format = args(3)
    
    val io = new IOCommon()
    val data = io.load(filename, sc, format)

    val searched = data.filter{ case (x,y) => regex.pattern.matcher(y).matches }

    val sorted = searched.map{ case (x,y) => (y,1) }
                 .reduceByKey(_ + _)
                 .map{ case (y,n) => (n,y)}
                 .sortByKey(numPartitions = 1)

    io.save[Int,String](save_file, sorted, sc, format)
    //sc.stop()
  }
}
