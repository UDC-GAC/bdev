package es.udc.gac.sparkbench.dataset

import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions._
import es.udc.gac.sparkbench.IOCommon

object ScalaConnectedComponents {

  def main(args: Array[String]) {

    if (args.length < 4) {
      System.err.println("Usage: ScalaConnectedComponents <INPUT_PATH> <OUTPUT_PATH> <PAGES> <MAX_ITERATIONS>")
      System.exit(1)
    }

    val session = SparkSession.builder().appName("SparkBench ScalaConnectedComponents").getOrCreate()
    import session.implicits._

    val filename = args(0)
    val save_file = args(1)
    val number_nodes = args(2).toLong
    var max_iter = args(3).toInt

    if (max_iter > 2048)
      max_iter = 2048

    val io = new IOCommon()
    
    val data = io.load_dataset(filename, session, "KeyValueText")
      .select($"index".cast("long").as("src"), $"value".cast("long").as("dst"))

    // "nosym": Information flows from the destination to the source
    // We convert the input to (dst, src) instead of (src, dst)
    val edges = data.distinct()
      .groupBy("dst")
      .agg(collect_list("src").as("srcs"))
      .withColumnRenamed("dst", "key")
      .repartition($"key")
      .cache()

    edges.count()

    var components = session.range(number_nodes)
      .withColumnRenamed("id", "key")
      .withColumn("component", $"key")
      .repartition($"key")
      .cache()

    components.count()

    var finished = false
    var i = 0

    while (i < max_iter && !finished) {
      println("Iteration " + i)

      // The "dst" sends its current component to all "src" that pointed to it
      val propagated = edges
        .join(components, Seq("key"))
        .select(explode($"srcs").as("key"), $"component")

      var previous_components = components

      // Each node keeps the min() (select the minimum neighbor)
      val newComponents = propagated.union(previous_components)
        .groupBy("key")
        .agg(min("component").as("component"))
        .localCheckpoint()

      newComponents.count()
      components = newComponents

      // Check if there were any changes (if any node has reduced its ID)
      val changed = components.alias("curr")
        .join(previous_components.alias("prev"), Seq("key"))
        .filter($"curr.component" < $"prev.component")

      if (changed.isEmpty) {
        println("Connected Components converged")
        finished = true
      }

      previous_components.unpersist()
      i = i + 1
    }

    if (!finished) {
        println("Reached maximum number of iterations")
    }

    val result = components
      .select($"key".cast("string"), $"component".cast("string"))
      .as[(String, String)]

    io.save_dataset(save_file, result, session, "Text")
    session.stop()
  }
}
