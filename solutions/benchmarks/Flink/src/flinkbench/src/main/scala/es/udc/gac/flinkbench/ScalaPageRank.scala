package es.udc.gac.flinkbench

import java.lang.Iterable

import org.apache.flink.api.common.functions.GroupReduceFunction
import org.apache.flink.api.java.utils.ParameterTool
import org.apache.flink.api.scala._
import org.apache.flink.api.java.aggregation.Aggregations.SUM
import org.apache.flink.util.Collector

import scala.collection.JavaConverters._

object ScalaPageRank {

  def main(args: Array[String]) {
    if (args.size < 4) {
      System.err.println("Usage: ScalaPageRank <INPUT_PATH> <OUTPUT_PATH> <PAGES> <MAX_ITERATIONS>")
      System.exit(1)
    }

    val env = ExecutionEnvironment.getExecutionEnvironment
    env.getConfig.enableObjectReuse()

    val inputPath = args(0)
    val outputPath = args(1)

    val number_nodes = args(2).toDouble
    val max_iter = args(3).toInt

    val converge_threshold = (1.0 / number_nodes) / 10
    val mixing_c = 0.85f
    val random_coeff = (1.0 - mixing_c) / number_nodes
    val initial_rank = 1.0 / number_nodes

    val io = new IOCommon(env)
    val data = io.load(inputPath, "KeyValueText")

    val links = data.distinct().groupBy(0)
      .reduceGroup(new GroupReduceFunction[(String, String), (String, List[String])] {
        override def reduce(in: Iterable[(String, String)], out: Collector[(String, List[String])]): Unit = {
          var outputId = "-1"
          val outputList = in.asScala map { t => outputId = t._1; t._2 }
          out.collect((outputId, outputList.toList))
	}
      }).rebalance()

    // assign initial ranks to pages
    val initialRanks = links.flatMap {
      (adj, out: Collector[(String, Double)]) =>
        {
          val targets = adj._2
          val rankPerTarget = initial_rank * mixing_c / targets.length

          // dampen fraction to targets
          for (target <- targets) {
            out.collect((target, rankPerTarget))
          }

          // random jump to self
          out.collect((adj._1, random_coeff))
        }
    }.groupBy(0).sum(1)

    val initialDeltas = initialRanks
      .map { (page) => (page._1, page._2 - initial_rank) }.withForwardedFields("_1")

    val finalRanks = initialRanks
      .iterateDelta(initialDeltas, max_iter, Array(0)) {
       (solutionSet, workset) =>
       {
          val deltas = workset.join(links).where(0).equalTo(0) {
            (lastDeltas, adj, out: Collector[(String, Double)]) =>
              {
                val targets = adj._2
                val deltaPerTarget = mixing_c * lastDeltas._2 / targets.length

                for (target <- targets) {
                  out.collect((target, deltaPerTarget))
                }
              }
          }.groupBy(0).sum(1)
           .filter(x => Math.abs(x._2) > converge_threshold)

          val rankUpdates = solutionSet.join(deltas).where(0).equalTo(0) {
            (current, delta) => (current._1, current._2 + delta._2)
          }.withForwardedFieldsFirst("_1")

          (rankUpdates, deltas)
       }
    }

    io.save(outputPath, finalRanks, "Text")

    env.execute("FlinkBench ScalaPageRank")
  }
}
