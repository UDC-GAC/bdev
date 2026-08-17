package es.udc.gac.sparkbench.rdd

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark._
import org.apache.spark.rdd._
import org.apache.spark.graphx._
import org.apache.spark.graphx.lib._
import es.udc.gac.sparkbench.IOCommon

object ScalaPageRank {

  def main(args: Array[String]) {

    if (args.length < 4) {
      System.err.println("Usage: ScalaPageRank <INPUT_PATH> <OUTPUT_PATH> <PAGES> <MAX_ITERATIONS>")
      System.exit(1)
    }

    val conf = new SparkConf().setAppName("SparkBench ScalaNaivePageRank")
    val sc = new SparkContext(conf)

    val filename = args(0)
    val save_file = args(1)
    val number_nodes = args(2).toLong
    val max_iter = args(3).toInt

    val converge_threshold = (1.0 / number_nodes) / 10
    val mixing_c = 0.85f
    val random_coeff = (1.0 - mixing_c) / number_nodes
    val initial_rank = 1.0 / number_nodes

    val io = new IOCommon()
    val raw_data = io.load_rdd(filename, sc, "KeyValueText")

    val numPartitions = raw_data.partitions.length
    val partitioner = new HashPartitioner(numPartitions)

    // "nosym": Natural direct flow (src -> dst)
    val edges = raw_data.map { case (src, dst) => (src.toLong, dst.toLong) }.distinct()
    
    val links = data.distinct().groupByKey(partitioner).cache()
    links.count()

    // "new": Explicit initialization of the entire universe
    var ranks = sc.range(0L, number_nodes, 1, numPartitions)
      .map(n => (n, initial_rank))
      .partitionBy(partitioner)
      .cache()
      
    ranks.count()
    
    var finished = false
    var i = 0
    
    while (i < max_iter && !finished) {
      println("Iteration " + i)

      val contribs = links.join(ranks).values.flatMap {
        case (urls, rank) =>
          val size = urls.size
          urls.map(url => (url, rank / size))
      }

      var previous_ranks = ranks

      val summed_contribs = contribs.reduceByKey(partitioner, _ + _)

      // We use rightOuterJoin against the entire universe
      // If a node receives no links (incomingSumOpt is empty), its next_rank
      // will simply be (0.0 * mixing_c + random_coeff), preventing it from being removed from the graph.
      ranks = summed_contribs.rightOuterJoin(previous_ranks)
        .mapValues { case (incomingSumOpt, prevRank) =>
          incomingSumOpt.getOrElse(0.0) * mixing_c + random_coeff
        }
        .localCheckpoint()
        .cache()
      
      ranks.count()
      
      val changed = ranks.join(previous_ranks).values
        .filter {
          case (actual_rank, previous_rank) =>
            Math.abs(previous_rank - actual_rank) > converge_threshold
        }

      if (changed.isEmpty()) {
        println("PageRank converged")
        finished = true
      }

      previous_ranks.unpersist()
      i = i + 1
    }

    if (!finished) {
        println("Reached maximum number of iterations")
    }

    val result = ranks.map { case (node, rank) => (node.toString, rank) }
    
    io.save_rdd[String, Double](save_file, result, sc, "Text")
    sc.stop()
  }
}
