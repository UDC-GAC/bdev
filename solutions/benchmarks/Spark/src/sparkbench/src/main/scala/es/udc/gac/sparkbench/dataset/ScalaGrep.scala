package es.udc.gac.sparkbench.dataset

import org.apache.spark.{ SparkConf, SparkContext }
import org.apache.spark._
import org.apache.spark.rdd._
import es.udc.gac.sparkbench.IOCommon
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions._
import org.apache.spark.sql.expressions.Window

object ScalaGrep {

  def main(args: Array[String]) {

    if (args.length < 3) {
      System.err.println("Usage: ScalaGrep <INPUT_PATH> <OUTPUT_PATH> <REG_EX> [ Sequence | KeyValueText ]")
      System.exit(1)
    }
    val session = SparkSession.builder().appName("SparkBench ScalaGrep").getOrCreate()
    import session.implicits._

    val filename = args(0)
    val save_file = args(1)
    val regex = args(2).r
    
    var format = "Sequence"
    if (args.length > 3){
      format = args(3)
    }
    
    val io = new IOCommon()
    val data = io.load_dataset(filename, session, format)

    val searched = data.filter( x => regex.pattern.matcher(x._2).matches )


    val sorted = searched
      .groupBy("value").agg(count("*").as("count")).as[(String, BigInt)]
      .sort($"count")
      .map{ case (line: String, count: BigInt) => (count.toString(),line)}

    io.save_dataset(save_file, sorted, session, format)
    //sc.stop()
  }
}
