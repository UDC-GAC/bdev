package es.udc.gac.flinkbench

import org.apache.flink.api.scala._
import org.apache.flink.api.java.{DataSet => JavaDataSet}
import org.apache.flink.graph.scala._
import org.apache.flink.graph.examples.PageRank
import org.apache.flink.graph.scala.Graph
import org.apache.flink.graph.GraphAlgorithm
import org.apache.flink.graph.Edge
import org.apache.flink.graph.Vertex
import org.apache.flink.types.NullValue

import scala.collection.JavaConverters._

object ScalaGellyPageRank {

  def main(args: Array[String]) {
    if (args.size < 4) {
      System.err.println("Usage: ScalaGellyPageRank <INPUT_PATH> <OUTPUT_PATH> <PAGES> <MAX_ITERATIONS>")
      System.exit(1)
    }

    val env = ExecutionEnvironment.getExecutionEnvironment
    env.getConfig.enableObjectReuse()

    val inputPath = args(0)
    val outputPath = args(1)

    val number_nodes = args(2).toInt
    var maxIterations = args(3).toInt

    val converge_threshold = (1.0 / number_nodes) / 10
    val mixing_c = 0.85f
    val initial_rank = 1.0 / number_nodes
    
    val io = new IOCommon(env)
    val data = io.load(inputPath, "KeyValueText")

    val vertices: DataSet[Vertex[Long, Double]] = data.map { p => p._1 }.distinct()
      .map(n => new Vertex[Long, Double](n.toLong, initial_rank))

    val edges: DataSet[Edge[Long, Double]] =
      data.map(edge => new Edge[Long, Double](edge._1.toLong, edge._2.toLong, 1.0))

    // Create graph
    val graph = Graph.fromDataSet(vertices, edges, env)

    // Create PageRank object
    val pr: GraphAlgorithm[Long, Double, Double, JavaDataSet[Vertex[Long, Double]]] = 
      new PageRank[Long](mixing_c, maxIterations)
      .asInstanceOf[GraphAlgorithm[Long, Double, Double, JavaDataSet[Vertex[Long, Double]]]]
    
    // Run PageRank until convergence or maxIterations
    val result: DataSet[(Long, Double)] = new DataSet(graph.run(pr))
      .map(v => (v.getId, v.getValue))

    io.save(outputPath, result, "Text")

    env.execute("FlinkBench ScalaGellyPageRank")
  }
}
