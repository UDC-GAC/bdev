package es.udc.gac.sparkbench.dataset

import org.apache.hadoop.examples.terasort.{TeraInputFormat,TeraOutputFormat}
import org.apache.hadoop.io.Text
import org.apache.spark._
import org.apache.spark.rdd._
import org.apache.spark.SparkContext._

import scala.reflect.ClassTag
import Ordering.Implicits._
import org.apache.spark.sql.SparkSession
import es.udc.gac.sparkbench.IOCommon

object ScalaTeraSort {


  implicit def ArrayByteOrdering: Ordering[Array[Byte]] = Ordering.by((_: Array[Byte]).toIterable)


  def main(args: Array[String]) {
    
    if (args.length < 2) {
      System.err.println("Usage: ScalaTeraSort <INPUT_PATH> <OUTPUT_PATH>")
      System.exit(1)
    }
    

    val session = SparkSession.builder().appName("SparkBench ScalaTeraSort").getOrCreate()
    import session.implicits._
    val filename = args(0)
    val save_file = args(1)

    val io = new IOCommon()

    val data = 
      session.sparkContext.
      newAPIHadoopFile[Text, Text, TeraInputFormat](filename).
      map{case (k,v)=>(k.getBytes, v.getBytes)}.
      toDS()
    
    val parallel = session.sparkContext.getConf.getInt(
      "spark.default.parallelism", 
      session.sparkContext.defaultParallelism
    )

    val sorted_data = data.
      repartitionByRange(parallel, $"_1").
      sortWithinPartitions($"_1")

    sorted_data.
      rdd.
      map{ case (a: Array[Byte], b: Array[Byte]) => (new Text(a), new Text(b))}.
      saveAsNewAPIHadoopFile[TeraOutputFormat](save_file)
  }
}
