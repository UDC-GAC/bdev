package es.udc.gac.flinkbench

import org.apache.flink.api.scala._
import org.apache.flink.api.common.operators.Order

object ScalaSort {

  def main(args: Array[String]){
    if(args.size < 2){
      println("Usage: ScalaSort <INPUT_PATH> <OUTPUT_PATH> [ Sequence | KeyValueText ]")
      return
    }

    val env = ExecutionEnvironment.getExecutionEnvironment
    env.getConfig.enableObjectReuse()

    val inputPath= args(0)
    val outputPath = args(1)

    var format = "Sequence"
    if (args.length > 2)
      format = args(2)

    val io = new IOCommon(env)
    val data = io.load(inputPath, format) 
    
    val outputData = data
      .partitionByHash(0)
      .sortPartition(0,Order.ASCENDING)
    
    io.save(outputPath, outputData, format)
    
    env.execute("FlinkBench ScalaSort")
  }
}