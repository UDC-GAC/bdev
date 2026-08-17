package es.udc.gac.flinkbench.dataset

import java.lang.Iterable

import org.apache.flink.api.common.functions.GroupReduceFunction
import org.apache.flink.api.scala._
import org.apache.flink.util.Collector

import scala.collection.JavaConverters._
import es.udc.gac.flinkbench.IOCommon

object ScalaConnectedComponents {

  def main(args: Array[String]) {
    if (args.size < 4) {
      System.err.println("Usage: ScalaConnectedComponents <INPUT_PATH> <OUTPUT_PATH> <PAGES> <MAX_ITERATIONS>")
      System.exit(1)
    }

    val env = ExecutionEnvironment.getExecutionEnvironment

    val inputPath = args(0)
    val outputPath = args(1)
    val number_nodes = args(2).toLong
    var max_iter = args(3).toInt

    if (max_iter > 2048)
      max_iter = 2048

    val io = new IOCommon(env)
    val data = io.load(inputPath, "KeyValueText").map { p => (p._1.toLong, p._2.toLong) }

    // "nosym": Information flows from the destination to the source
    // We convert the input to (dst, src) instead of (src, dst)
    val edges = data.groupBy(1)
      .reduceGroup(new GroupReduceFunction[(Long, Long), (Long, Array[Long])] {
        override def reduce(in: Iterable[(Long, Long)], out: Collector[(Long, Array[Long])]): Unit = {
          val edgesList = in.asScala.toSeq
          if (edgesList.nonEmpty) {
            out.collect((edgesList.head._2, edgesList.map(_._1).toArray))
          }
        }
      }).rebalance()

    // "new": Explicit initialization of the entire universe
    val vertices = env.generateSequence(0L, number_nodes - 1L).map { n => (n, n) }
    
    // open a delta iteration (Native cyclic graph)
    val verticesWithComponents = vertices
      .iterateDelta(vertices, max_iter, Array(0)) { (s, ws) =>

        // The "dst" sends its current component to all "src" that pointed to it
        val allNeighbors = ws.join(edges).where(0).equalTo(0) {
          (vertex, adj, out: Collector[(Long, Long)]) =>
            val currentComp = vertex._2
            for (target <- adj._2) {
              out.collect((target, currentComp)) // (src, component_received)
            }
        }.withForwardedFieldsFirst("_2")

        // Each node keeps the min() (select the minimum neighbor)
        val minNeighbors = allNeighbors.groupBy(0).min(1)

        // update if the component of the candidate is smaller
        val updatedComponents = minNeighbors.join(s).where(0).equalTo(0) {
          (newVertex, oldVertex, out: Collector[(Long, Long)]) =>
            if (newVertex._2 < oldVertex._2) {
              out.collect(newVertex)
            }
        }.withForwardedFieldsFirst("_1")
        
        // delta and new workset are identical
        (updatedComponents, updatedComponents)
    }

    val result = verticesWithComponents.map(v => (v._1.toString, v._2.toString))
    io.save(outputPath, result, "Text")

    env.execute("FlinkBench ScalaConnectedComponents")
  }

}
