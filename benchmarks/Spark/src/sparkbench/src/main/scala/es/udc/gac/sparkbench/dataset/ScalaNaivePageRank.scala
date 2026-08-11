package es.udc.gac.sparkbench.dataset

import org.apache.spark.{ SparkConf, SparkContext }
import org.apache.spark._
import org.apache.spark.rdd._
import org.apache.spark.graphx._
import org.apache.spark.graphx.lib._
import es.udc.gac.sparkbench.IOCommon
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions._

object ScalaNaivePageRank {

  def main(args: Array[String]) {

    if (args.length < 4) {
      System.err.println("Usage: ScalaNaivePageRank <INPUT_PATH> <OUTPUT_PATH> <PAGES> <MAX_ITERATIONS>")
      System.exit(1)
    }

    val session = SparkSession.builder().appName("SparkBench ScalaNaivePageRank").getOrCreate()
    import session.implicits._

    val filename = args(0)
    val save_file = args(1)
    val number_nodes = args(2).toDouble
    val max_iter = args(3).toInt

    val converge_threshold = (1.0 / number_nodes) / 10
    val mixing_c = 0.85f
    val random_coeff = (1.0 - mixing_c) / number_nodes
    val initial_rank = 1.0 / number_nodes

    val io = new IOCommon()
    val data = io.
      load_dataset(filename, session, "KeyValueText").
      withColumnRenamed("index", "key")

    val links = data.distinct().groupBy("key").agg(collect_list("value").as("urls")).as[(String, List[String])]
    var ranks = links.
      map{ case (a: String, b: List[String]) => (a, initial_rank)}.
      withColumnRenamed("_1", "key").withColumnRenamed("_2", "rank").
      as[(String, Double)]
    
    var finished = false

    var i = 0
    while (i < max_iter && !finished) {
      println("Iteration " + i)
      val contribs = links
        .join(ranks, Seq("key")).as[(String, List[String], Double)]
        .select($"urls", $"rank").as[(List[String], Double)]
        .flatMap{ case (urls: List[String], rank: Double) => {
          val size = urls.size
          urls.map(url => (url, rank / size))
        }}.withColumnRenamed("_1", "key").withColumnRenamed("_2", "contrib").as[(String, Double)]
      

      var previous_ranks = ranks
      ranks = contribs
        .groupBy("key").agg(sum("contrib").as("value")).as[(String, Double)]
        .map{case (key: String, value: Double) => (key, random_coeff + mixing_c * value)}
        .withColumnRenamed("_1","key").withColumnRenamed("_2", "rank").as[(String, Double)]
      
      

      val changed = ranks.alias("ranks").join(previous_ranks.alias("previous_ranks"), Seq("key"))
        .select($"ranks.rank".as("actual_rank"), $"previous_ranks.rank".as("previous_ranks")).as[(Double, Double)]
        .filter((data: (Double, Double)) =>
          Math.abs(data._2 - data._1) > converge_threshold
        )

      if (changed.isEmpty) {
        println("PageRank converged")
        finished = true
      }

      i = i + 1
    }

    val result = ranks.
      map{case (key: String, value: Double) => (key, value.toString())}.
      as[(String, String)]


    io.save_dataset(save_file, result, session, "Text")
    //sc.stop()
  }
}
