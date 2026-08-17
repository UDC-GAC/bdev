package es.udc.gac.sparkbench.rdd

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.HashPartitioner
import es.udc.gac.sparkbench.IOCommon

object ScalaConnectedComponents {

  def main(args: Array[String]) {
    if (args.length < 4) {
      System.err.println("Usage: ScalaConnectedComponents <INPUT_PATH> <OUTPUT_PATH> <PAGES> <MAX_ITERATIONS>")
      System.exit(1)
    }

    val conf = new SparkConf().setAppName("SparkBench ScalaConnectedComponents")
    val sc = new SparkContext(conf)

    val filename = args(0)
    val save_file = args(1)
    val number_nodes = args(2).toLong
    var max_iter = args(3).toInt

    if (max_iter > 2048)
      max_iter = 2048

    val io = new IOCommon()
    val raw_data = io.load_rdd(filename, sc, "KeyValueText")

    val numPartitions = raw_data.partitions.length
    val partitioner = new HashPartitioner(numPartitions)

    // "nosym": Information flows from the destination to the source.
    // We convert the input to (dst, src) instead of (src, dst)
    val edges = raw_data.map { case (src, dst) => (dst.toLong, src.toLong) }

    val links = edges.groupByKey(partitioner).cache()
    links.count()

 
    var components = sc.range(0, number_nodes, 1, numPartitions)
      .map(n => (n, n))
      .partitionBy(partitioner)
      .cache()
    
    components.count()

    var finished = false
    var i = 0

    while (i < max_iter && !finished) {
      println("Iteration " + i)

      // The "dst" sends its current component to all "src" that pointed to it
      val propagated = links.join(components).values.flatMap {
        case (srcs, currentComp) => srcs.map(src => (src, currentComp))
      }

      var previous_components = components

      // Each node keeps the min() (select the minimum neighbor)
      components = propagated.union(previous_components)
        .reduceByKey(partitioner, (a, b) => math.min(a, b))
        .cache()

      components.count()

      // Check if there were any changes (if any node has reduced its ID)
      val changed = components.join(previous_components).values
        .filter {
          case (actual_comp, previous_comp) => actual_comp < previous_comp
        }

      if (changed.isEmpty()) {
        println("Connected Components converged")
        finished = true
      }

      previous_components.unpersist()
      i = i + 1
    }

    val result = components.map { case (node, comp) => (node.toString, comp.toString) }
    io.save_rdd[String, String](save_file, result, sc, "Text")
    
    sc.stop()
  }
}
