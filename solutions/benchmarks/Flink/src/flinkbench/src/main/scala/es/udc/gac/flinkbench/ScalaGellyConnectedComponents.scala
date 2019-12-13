package es.udc.gac.flinkbench

import java.lang.Long

import org.apache.flink.api.scala._
import org.apache.flink.api.java.{DataSet => JavaDataSet}
import org.apache.flink.graph.scala._
import org.apache.flink.graph.library.ConnectedComponents
import org.apache.flink.graph.scala.Graph
import org.apache.flink.graph.GraphAlgorithm
import org.apache.flink.graph.Edge
import org.apache.flink.graph.Vertex
import org.apache.flink.types.NullValue


object ScalaGellyConnectedComponents {

  def main(args: Array[String]) {
    if (args.size < 4) {
      System.err.println("Usage: ScalaGellyConnectedComponents <INPUT_PATH> <OUTPUT_PATH> <PAGES> <MAX_ITERATIONS>")
      System.exit(1)
    }

    val env = ExecutionEnvironment.getExecutionEnvironment
    env.getConfig.enableObjectReuse()

    val inputPath = args(0)
    val outputPath = args(1)

    val number_nodes = args(2).toDouble
    var maxIterations = args(3).toInt

    if (maxIterations > 2048)
      maxIterations = 2048

    val io = new IOCommon(env)
    val data = io.load(inputPath, "KeyValueText")

    val vertices: DataSet[Vertex[Long, Long]] = data.map { p => p._1 }
      .distinct()
      .map(n => new Vertex[Long, Long](n.toLong, n.toLong))

    val edges: DataSet[Edge[Long, NullValue]] =
      data.map(edge => new Edge[Long, NullValue](edge._1.toLong, edge._2.toLong, NullValue.getInstance))

    // Create graph
    val graph = Graph.fromDataSet[Long, Long, NullValue](vertices, edges, env)

    // Create ConnectedComponents object
    val cc: GraphAlgorithm[Long, Long, NullValue, JavaDataSet[Vertex[Long, Long]]] = 
      new ConnectedComponents[Long, Long, NullValue](maxIterations)

    // Run ConnectedComponents until convergence or maxIterations
    val result: DataSet[(Long, Long)] = new DataSet(graph.run(cc))
      .map(v => (v.getId, v.getValue))

    io.save(outputPath, result, "Text")

    env.execute("FlinkBench ScalaGellyConnectedComponents")
  }
}
