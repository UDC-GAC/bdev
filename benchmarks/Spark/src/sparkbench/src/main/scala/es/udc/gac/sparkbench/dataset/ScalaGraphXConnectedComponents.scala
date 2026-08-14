package es.udc.gac.sparkbench.dataset

import org.apache.spark.SparkConf
import org.apache.spark.graphx._
import org.apache.spark.graphx.lib._
import org.apache.spark.sql.SparkSession
import org.apache.spark.rdd.RDD
import es.udc.gac.sparkbench.IOCommon

object ScalaGraphXConnectedComponents {

  def main(args: Array[String]) {

    if (args.length < 4) {
      System.err.println("Usage: ScalaGraphXConnectedComponents <INPUT_PATH> <OUTPUT_PATH> <PAGES> <MAX_ITERATIONS>")
      System.exit(1)
    }

    val session = SparkSession.builder()
      .appName("SparkBench ScalaGraphXConnectedComponents")
      .getOrCreate()
    
    import session.implicits._

    val filename = args(0)
    val save_file = args(1)
    val number_nodes = args(2).toDouble
    var maxIterations = args(3).toInt

    if (maxIterations > 2048)
      maxIterations = 2048

    val io = new IOCommon()
    val data = io.load_dataset(filename, session, "KeyValueText")

    // Load the edges as a graph
    val graph = EnhancedGraphLoader.edgeListDataset(data)

     // Run ConnectedComponents until convergence or maxIterations (Spark >= 2.x)
    val vertices: RDD[(VertexId, VertexId)] = ConnectedComponents.run(graph, maxIterations).vertices

    val resultDS = vertices
      .map { case (vertexId, componentId) => (vertexId.toString, componentId.toString) }
      .toDS()

    io.save_dataset(save_file, resultDS, session, "Text")    
    session.stop()
  }
}
