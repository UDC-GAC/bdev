package es.udc.gac.sparkbench.rdd

import org.apache.spark.{ SparkConf, SparkContext }
import org.apache.spark._
import org.apache.spark.rdd._
import org.apache.spark.graphx._
import org.apache.spark.graphx.lib._
import es.udc.gac.sparkbench.IOCommon

object ScalaGraphXPageRank {

  def main(args: Array[String]) {

    if (args.length < 3) {
      System.err.println("Usage: ScalaGraphxPageRank <INPUT_PATH> <OUTPUT_PATH> <PAGES>")
      System.exit(1)
    }

    val conf = new SparkConf().setAppName("SparkBench ScalaGraphxPageRank")
    val sc = new SparkContext(conf)

    val filename = args(0)
    val save_file = args(1)
    val number_nodes = args(2).toDouble

    val converge_threshold = (1.0 / number_nodes) / 10
    val mixing_c = 0.85f

    val io = new IOCommon()
    val data = io.load(filename, sc, "KeyValueText")

    // Load the edges as a graph
    val graph = EnhancedGraphLoader.edgeListRDD(data)
    
    // Run PageRank until convergence
    val ranks: RDD[(VertexId, Double)] = PageRank.runUntilConvergence(graph, converge_threshold, 1 - mixing_c).vertices

    io.save[VertexId, Double](save_file, ranks, sc, "Text")
    //sc.stop()
  }
}
