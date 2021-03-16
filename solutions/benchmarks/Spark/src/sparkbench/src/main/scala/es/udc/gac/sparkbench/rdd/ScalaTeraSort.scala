package es.udc.gac.sparkbench.rdd

import org.apache.hadoop.examples.terasort.{TeraInputFormat,TeraOutputFormat}
import org.apache.hadoop.io.Text
import org.apache.spark._
import org.apache.spark.rdd._
import org.apache.spark.SparkContext._

import scala.reflect.ClassTag
import Ordering.Implicits._

object ScalaTeraSort {

  //implicit def ArrayByteOrdering: Ordering[Array[Byte]] = Ordering.fromLessThan{case (a, b)=> a.compareTo(b)<0}

  implicit def ArrayByteOrdering: Ordering[Array[Byte]] = Ordering.by((_: Array[Byte]).toIterable)
  //implicit val ArrayByteOrdering = new Ordering[Array[Byte]] {
  //  override def compare(a: Array[Byte], b: Array[Byte]) = a.compareTo(b)
  //}

  def main(args: Array[String]) {
    
    if (args.length < 2) {
      System.err.println("Usage: ScalaTeraSort <INPUT_PATH> <OUTPUT_PATH>")
      System.exit(1)
    }
    
    val conf = new SparkConf().setAppName("SparkBench ScalaTeraSort")
    val sc = new SparkContext(conf)
    val filename = args(0)
    val save_file = args(1)

    val parallel = sc.getConf.getInt("spark.default.parallelism", sc.defaultParallelism)
    val data = sc.newAPIHadoopFile[Text, Text, TeraInputFormat](filename).map{case (k,v)=>(k.getBytes, v.getBytes)}
    val partitioner = new RangePartitioner(partitions = parallel, rdd = data)
    val sorted_data = data.repartitionAndSortWithinPartitions(partitioner = partitioner).map{case (k, v)=>(new Text(k), new Text(v))}

    sorted_data.saveAsNewAPIHadoopFile[TeraOutputFormat](save_file)
    //sc.stop()
  }
}
