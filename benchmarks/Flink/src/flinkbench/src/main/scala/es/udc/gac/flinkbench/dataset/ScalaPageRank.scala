package es.udc.gac.flinkbench.dataset

import java.lang.Iterable

import org.apache.flink.api.common.functions.GroupReduceFunction
import org.apache.flink.api.java.utils.ParameterTool
import org.apache.flink.api.scala._
import org.apache.flink.api.java.aggregation.Aggregations.SUM
import org.apache.flink.util.Collector

import scala.collection.JavaConverters._

import es.udc.gac.flinkbench.IOCommon

object ScalaPageRank {

  def main(args: Array[String]) {
    if (args.size < 4) {
      System.err.println("Usage: ScalaPageRank <INPUT_PATH> <OUTPUT_PATH> <PAGES> <MAX_ITERATIONS>")
      System.exit(1)
    }

    val env = ExecutionEnvironment.getExecutionEnvironment

    val inputPath = args(0)
    val outputPath = args(1)
    val number_nodes = args(2).toLong
    val max_iter = args(3).toInt

    val converge_threshold = (1.0 / number_nodes) / 10
    val mixing_c = 0.85f
    val random_coeff = (1.0 - mixing_c) / number_nodes
    val initial_rank = 1.0 / number_nodes

    val io = new IOCommon(env)
	val data = io.load(inputPath, "KeyValueText").map { p => (p._1.toLong, p._2.toLong) }

	// "nosym": Information flows from the destination to the source
    // We convert the input to (dst, src) instead of (src, dst)
	val links = data.distinct().groupBy(0)
      .reduceGroup(new GroupReduceFunction[(Long, Long), (Long, Array[Long])] {
        override def reduce(in: Iterable[(Long, Long)], out: Collector[(Long, Array[Long])]): Unit = {
          val edgesList = in.asScala.toSeq
          if (edgesList.nonEmpty) {
            out.collect((edgesList.head._1, edgesList.map(_._2).toArray))
          }
        }
      }).rebalance()

	// "new": Explicit initialization of the entire universe
    val initialRanks = env.generateSequence(0L, number_nodes - 1L).map(n => (n, initial_rank))

	// iterateWithTermination exactly emulates the Bulk iteration of Pegasus and Spark
	val finalRanks = initialRanks.iterateWithTermination(max_iter) { currentRanks =>

		val contribs = currentRanks.join(links).where(0).equalTo(0) {
        (rank, adj, out: Collector[(Long, Double)]) =>
          val targets = adj._2
          val rankPerTarget = rank._2 / targets.length
          for (target <- targets) {
            out.collect((target, rankPerTarget))
          }
      	}

      	val summedContribs = contribs.groupBy(0).sum(1)
		
      	val newRanks = summedContribs.rightOuterJoin(currentRanks).where(0).equalTo(0) {
        	(sumOpt, current, out: Collector[(Long, Double)]) =>
          		val incoming = if (sumOpt == null) 0.0 else sumOpt._2
          		val newRank = incoming * mixing_c + random_coeff
          		out.collect((current._1, newRank))
      	}.withForwardedFieldsSecond("_1")

      	val changed = newRanks.join(currentRanks).where(0).equalTo(0) {
        	(newR, oldR, out: Collector[(Long, Double)]) =>
          	if (Math.abs(oldR._2 - newR._2) > converge_threshold) {
            	out.collect(newR)
          	}
      	}

      	// If "changed" is empty, Flink automatically stops the cluster
      	(newRanks, changed)
    }

	val result = finalRanks.map(v => (v._1.toString, v._2))
    io.save(outputPath, result, "Text")

    env.execute("FlinkBench ScalaPageRank")
  }
}
