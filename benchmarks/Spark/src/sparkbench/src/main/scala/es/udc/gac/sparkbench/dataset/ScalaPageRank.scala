package es.udc.gac.sparkbench.dataset

import org.apache.spark.{ SparkConf, SparkContext }
import org.apache.spark._
import org.apache.spark.rdd._
import org.apache.spark.graphx._
import org.apache.spark.graphx.lib._
import es.udc.gac.sparkbench.IOCommon
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions._

object ScalaPageRank {

  def main(args: Array[String]) {

    if (args.length < 4) {
      System.err.println("Usage: ScalaPageRank <INPUT_PATH> <OUTPUT_PATH> <PAGES> <MAX_ITERATIONS>")
      System.exit(1)
    }

    val session = SparkSession.builder().appName("SparkBench ScalaNaivePageRank").getOrCreate()
    import session.implicits._

    val filename = args(0)
    val save_file = args(1)
    val number_nodes = args(2).toLong
    val max_iter = args(3).toInt

    val converge_threshold = (1.0 / number_nodes) / 10
    val mixing_c = 0.85f
    val random_coeff = (1.0 - mixing_c) / number_nodes
    val initial_rank = 1.0 / number_nodes

    val io = new IOCommon()
    val data = io.load_dataset(filename, session, "KeyValueText").
      .select($"index".cast("long").as("src"), $"value".cast("long").as("dst"))

    // "nosym": Information flows from the destination to the source
    // We convert the input to (dst, src) instead of (src, dst)
    val links = data.distinct()
      .groupBy("src")
      .agg(collect_list("dst").as("urls"))
      .withColumnRenamed("src", "node")
      .repartition($"node")
      .cache()
    
    links.count()

    // "new": Explicit initialization of the entire universe
    var ranks = session.range(number_nodes)
      .withColumnRenamed("id", "node")
      .withColumn("rank", lit(initial_rank))
      .repartition($"node")
      .cache()

    ranks.count()
    
    var finished = false
    var i = 0
    
    while (i < max_iter && !finished) {
      println("Iteration " + i)

      val contribs = links.join(ranks, Seq("node"))
        .select(
          explode($"urls").as("dst"), 
          ($"rank" / size($"urls")).as("contrib")
        )

      var previous_ranks = ranks

      val newRanks = contribs
        .groupBy("dst")
        .agg(sum("contrib").as("incoming_sum"))
        .join(previous_ranks, $"dst" === $"node", "right_outer")
        .select(
          $"node",
          (coalesce($"incoming_sum", lit(0.0)) * mixing_c + random_coeff).as("rank")
        )
        .localCheckpoint()
        .cache()
    
      newRanks.count()
      ranks = newRanks

      val changed = ranks.alias("curr")
        .join(previous_ranks.alias("prev"), Seq("node"))
        .filter(abs($"curr.rank" - $"prev.rank") > converge_threshold)

      if (changed.isEmpty) {
        println("PageRank converged")
        finished = true
      }
      
      previous_ranks.unpersist()
      i = i + 1
    }

    if (!finished) {
        println("Reached maximum number of iterations")
    }

    val result = ranks
      .select($"node".cast("string").as("_1"), $"rank".cast("string").as("_2"))
      .as[(String, String)]
    
    io.save_dataset(save_file, result, session, "Text")
    session.stop()
  }
}
