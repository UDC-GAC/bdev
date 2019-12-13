package es.udc.gac.flinkbench

import org.apache.flink.api.scala._
import org.apache.flink.hadoopcompatibility.scala.HadoopInputs
import org.apache.flink.api.scala.hadoop.mapreduce.HadoopOutputFormat

import org.apache.hadoop.fs.Path
import org.apache.hadoop.io.{ LongWritable, NullWritable, Text }
import org.apache.hadoop.mapreduce.lib.input.KeyValueTextInputFormat
import org.apache.hadoop.mapreduce.lib.input.SequenceFileInputFormat
import org.apache.hadoop.mapreduce.lib.output.SequenceFileOutputFormat
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat
import org.apache.hadoop.mapred.JobConf
import org.apache.hadoop.mapreduce.Job

class IOCommon(val env: ExecutionEnvironment) {

  def load(inputPath: String, input_format: String = "Sequence") = {

    input_format match {
      case "Text" =>
        env.createInput(HadoopInputs.readHadoopFile(new TextInputFormat, classOf[LongWritable], classOf[Text], inputPath))
          .map(x => (x._1.toString, x._2.toString))

      case "KeyValueText" =>
        env.createInput(HadoopInputs.readHadoopFile(new KeyValueTextInputFormat, classOf[Text], classOf[Text], inputPath))
          .map(x => (x._1.toString, x._2.toString))

      case "Sequence" =>
        env.createInput(HadoopInputs.readSequenceFile(classOf[Text], classOf[Text], inputPath))
          .map(x => (x._1.toString, x._2.toString))

      case _ => throw new UnsupportedOperationException(s"Unknown input format: $input_format")
    }
  }

  def save[T1, T2](outputPath: String, data: DataSet[(T1, T2)], output_format: String = "Sequence") = {
    val mapredConf = new JobConf()
    val jobContext = Job.getInstance(mapredConf)

    FileOutputFormat.setOutputPath(jobContext, new Path(outputPath))
    jobContext.setOutputKeyClass(classOf[Text]);
    jobContext.setOutputValueClass(classOf[Text]);

    var of: FileOutputFormat[Text, Text] = null;
    output_format match {
      case "Text" =>
        of = new TextOutputFormat[Text, Text]()
        
      case "KeyValueText" =>
        of = new TextOutputFormat[Text, Text]()

      case "Sequence" =>
        of = new SequenceFileOutputFormat[Text, Text]()

      case _ => throw new UnsupportedOperationException(s"Unknown output format: $output_format")
    }

    val hadoopOutputFormat = new HadoopOutputFormat[Text, Text](of, jobContext)

    val textData = data
      .map(x => (new Text(x._1.toString), new Text(x._2.toString)))

    textData.output(hadoopOutputFormat)
  }
}
