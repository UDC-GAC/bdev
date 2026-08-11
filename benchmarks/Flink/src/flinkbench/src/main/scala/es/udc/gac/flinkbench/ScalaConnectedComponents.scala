package es.udc.gac.flinkbench

import java.lang.Iterable

import org.apache.flink.api.scala._
import org.apache.flink.util.Collector

object ScalaConnectedComponents {

  def main(args: Array[String]) {
    if (args.size < 4) {
      System.err.println("Usage: ScalaConnectedComponents <INPUT_PATH> <OUTPUT_PATH> <PAGES> <MAX_ITERATIONS>")
      System.exit(1)
    }

    val env = ExecutionEnvironment.getExecutionEnvironment
    env.getConfig.enableObjectReuse()

    val inputPath = args(0)
    val outputPath = args(1)

    val number_nodes = args(2).toDouble
    var max_iter = args(3).toInt

    if (max_iter > 2048)
      max_iter = 2048

    val io = new IOCommon(env)
    val data = io.load(inputPath, "KeyValueText")

    val vertices = data.map { p => p._1 }.distinct()
      .map { n => (n.toLong, n.toLong) }

    val edges = data
      .flatMap { edge => Seq((edge._1.toLong, edge._2.toLong),
          (edge._2.toLong, edge._1.toLong)) }
      .rebalance()
      
    // open a delta iteration
    val verticesWithComponents = vertices
      .iterateDelta(vertices, max_iter, Array("_1")) { (s, ws) =>

        // apply the step logic: join with the edges
        val allNeighbors = ws.join(edges).where(0).equalTo(0) {
          (vertex, edge) => (edge._2, vertex._2)
        }.withForwardedFieldsFirst("_2->_2").withForwardedFieldsSecond("_2->_1")

        // select the minimum neighbor
        val minNeighbors = allNeighbors.groupBy(0).min(1)

        // update if the component of the candidate is smaller
        val updatedComponents = minNeighbors.join(s).where(0).equalTo(0) {
          (newVertex, oldVertex, out: Collector[(Long, Long)]) =>
            if (newVertex._2 < oldVertex._2) out.collect(newVertex)
        }.withForwardedFieldsFirst("*")

        // delta and new workset are identical
        (updatedComponents, updatedComponents)
    }

    io.save(outputPath, verticesWithComponents, "Text")

    env.execute("FlinkBench ScalaConnectedComponents")
  }

}
