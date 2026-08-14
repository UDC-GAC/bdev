package es.udc.gac.sparkbench.dataset

import org.apache.spark.graphx._
import org.apache.spark.graphx.lib._
import org.apache.spark.sql.SparkSession
import org.apache.spark.rdd.RDD
import es.udc.gac.sparkbench.IOCommon

object ScalaGraphXPageRank {

  def main(args: Array[String]) {

    if (args.length < 3) {
      System.err.println("Usage: ScalaGraphxPageRank <INPUT_PATH> <OUTPUT_PATH> <PAGES>")
      System.exit(1)
    }

    val session = SparkSession.builder()
      .appName("SparkBench ScalaGraphxPageRank Dataset")
      .getOrCreate()
      
    import session.implicits._

    val filename = args(0)
    val save_file = args(1)
    val number_nodes = args(2).toDouble

    val converge_threshold = (1.0 / number_nodes) / 10
    val mixing_c = 0.85f

    val io = new IOCommon()
    val data = io.load_dataset(filename, session, "KeyValueText")

    // Load the edges as a graph
    val graph = EnhancedGraphLoader.edgeListDataset(data)
    
    // Run PageRank until convergence
    val ranks: RDD[(VertexId, Double)] = PageRank.runUntilConvergence(graph, converge_threshold, 1 - mixing_c).vertices

    val resultDS = ranks
      .map { case (vertexId, rank) => (vertexId.toString, rank.toString) }
      .toDS()

    io.save_dataset(save_file, resultDS, session, "Text")    
    session.stop()
  }
}
