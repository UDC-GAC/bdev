package es.udc.gac.sparkbench.rdd

import org.apache.spark.{ SparkConf, SparkContext }
import org.apache.spark._
import org.apache.spark.rdd._
import org.apache.spark.graphx._
import org.apache.spark.graphx.lib._
import es.udc.gac.sparkbench.IOCommon

object ScalaGraphXConnectedComponents {

  def main(args: Array[String]) {

    if (args.size < 4) {
      System.err.println("Usage: ScalaGraphXConnectedComponents <INPUT_PATH> <OUTPUT_PATH> <PAGES> <MAX_ITERATIONS>")
      System.exit(1)
    }

    val conf = new SparkConf().setAppName("SparkBench ScalaGraphXConnectedComponents")
    val sc = new SparkContext(conf)

    val filename = args(0)
    val save_file = args(1)
    val number_nodes = args(2).toDouble
    var maxIterations = args(3).toInt

    if (maxIterations > 2048)
      maxIterations = 2048

    val io = new IOCommon()
    val data = io.load(filename, sc, "KeyValueText")

    // Load the edges as a graph
    val graph = EnhancedGraphLoader.edgeListRDD(data)

    // Run ConnectedComponents until convergence (Spark < 2.x)
    //val vertices: RDD[(VertexId, VertexId)] = ConnectedComponents.run(graph).vertices

    // Run ConnectedComponents until convergence or maxIterations (Spark >= 2.x)
    val vertices: RDD[(VertexId, VertexId)] = ConnectedComponents.run(graph, maxIterations).vertices

    io.save[VertexId, VertexId](save_file, vertices, sc, "Text")
    //sc.stop()
  }
}
