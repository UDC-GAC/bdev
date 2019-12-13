package es.udc.gac.flinkbench

import java.lang.Iterable

import org.apache.flink.api.common.functions.GroupReduceFunction
import org.apache.flink.api.java.utils.ParameterTool
import org.apache.flink.api.scala._
import org.apache.flink.api.java.aggregation.Aggregations.SUM
import org.apache.flink.util.Collector

import scala.collection.JavaConverters._

object ScalaNaivePageRank {

  def main(args: Array[String]) {
    if (args.size < 4) {
      System.err.println("Usage: ScalaNaivePageRank <INPUT_PATH> <OUTPUT_PATH> <PAGES> <MAX_ITERATIONS>")
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
    val ranks = links.map { p => (p._1, initial_rank) }.distinct()

    val finalRanks = ranks.iterateWithTermination(max_iter) {
      currentRanks =>
	// distribute ranks to target pages
        val contribs = currentRanks.join(links).where(0).equalTo(0) {
          (rank, contrib, out: Collector[(String, Double)]) =>
            val size = contrib._2.size
            contrib._2 foreach { url => out.collect(url, rank._2 / size) }
        }

	// collect ranks and sum them up
        val newRanks = contribs.groupBy(0).aggregate(SUM, 1)
	  // apply dampening factor
          .map(t => (t._1, random_coeff + mixing_c * t._2))

	// terminate if no rank update was significant
        val changed = currentRanks.join(newRanks).where(0).equalTo(0) {
          (current_rank, next_rank, out: Collector[Int]) =>
            if (Math.abs(current_rank._2 - next_rank._2) > converge_threshold)
              out.collect(1)
	}

        (newRanks, changed)
    }

    io.save(outputPath, finalRanks, "Text")

    env.execute("FlinkBench ScalaNaivePageRank")
  }
}
