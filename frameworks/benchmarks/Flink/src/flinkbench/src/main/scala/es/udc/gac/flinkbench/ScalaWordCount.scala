package es.udc.gac.flinkbench

import org.apache.flink.api.scala._

object ScalaWordCount {

  def main(args: Array[String]){
    if(args.size < 2){
      println("Usage: ScalaWordCount <INPUT_PATH> <OUTPUT_PATH> [ Sequence | KeyValueText ]")
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
    
    val outputData = data.flatMap { x => (x._2.split(" |\t")) }
      .map { (_, 1) }
      .groupBy(0)
      .sum(1)
    
    io.save(outputPath, outputData, format)
    
    env.execute("FlinkBench ScalaWordCount")
  }
}