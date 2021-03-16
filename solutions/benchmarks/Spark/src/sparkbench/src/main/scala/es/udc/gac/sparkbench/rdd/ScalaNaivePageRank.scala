package es.udc.gac.sparkbench.rdd

import org.apache.spark.{ SparkConf, SparkContext }
import org.apache.spark._
import org.apache.spark.rdd._
import org.apache.spark.graphx._
import org.apache.spark.graphx.lib._
import es.udc.gac.sparkbench.IOCommon

object ScalaNaivePageRank {

  def main(args: Array[String]) {

    if (args.length < 4) {
      System.err.println("Usage: ScalaNaivePageRank <INPUT_PATH> <OUTPUT_PATH> <PAGES> <MAX_ITERATIONS>")
      System.exit(1)
    }

    val conf = new SparkConf().setAppName("SparkBench ScalaNaivePageRank")
    val sc = new SparkContext(conf)

    val filename = args(0)
    val save_file = args(1)
    val number_nodes = args(2).toDouble
    val max_iter = args(3).toInt

    val converge_threshold = (1.0 / number_nodes) / 10
    val mixing_c = 0.85f
    val random_coeff = (1.0 - mixing_c) / number_nodes
    val initial_rank = 1.0 / number_nodes

    val io = new IOCommon()
    val data = io.load(filename, sc, "KeyValueText")

    val links = data.distinct().groupByKey().cache()
    var ranks = links.mapValues(v => initial_rank)
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
      ranks = contribs.reduceByKey(_ + _).mapValues(random_coeff + mixing_c * _)

      val changed = ranks.join(previous_ranks).values
        .filter {
          case (actual_rank, previous_rank) =>
            Math.abs(previous_rank - actual_rank) > converge_threshold
        }

      if (changed.isEmpty()) {
        println("PageRank converged")
        finished = true
      }

      i = i + 1
    }

    io.save[String, Double](save_file, ranks, sc, "Text")
    //sc.stop()
  }
}
