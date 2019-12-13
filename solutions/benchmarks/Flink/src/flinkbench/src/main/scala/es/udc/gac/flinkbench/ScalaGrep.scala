package es.udc.gac.flinkbench

import org.apache.flink.api.scala._
import org.apache.flink.api.common.operators.Order

object ScalaGrep {

  def main(args: Array[String]) {
    if (args.size < 3) {
      println("Usage: ScalaGrep <INPUT_PATH> <OUTPUT_PATH> <REG_EX> [ Sequence | KeyValueText ]")
      return
    }

    val env = ExecutionEnvironment.getExecutionEnvironment
    env.getConfig.enableObjectReuse()

    val inputPath = args(0)
    val outputPath = args(1)
    val regex = args(2).r

    var format = "Sequence"
    if (args.length > 3)
      format = args(3)

    val io = new IOCommon(env)
    val data = io.load(inputPath, format)

    val searchedData = data.filter { p => regex.pattern.matcher(p._2).matches }

    val countedData = searchedData.map { p => (p._2, 1) }
      .groupBy(0)
      .reduce((x, y) => (x._1, x._2 + y._2))
      .map { p => (p._2, p._1) }

    val outputData = countedData
      .partitionByHash(0).setParallelism(1)
      .sortPartition(0, Order.ASCENDING)

    io.save(outputPath, outputData, format)

    env.execute("FlinkBench ScalaGrep")
  }

}
