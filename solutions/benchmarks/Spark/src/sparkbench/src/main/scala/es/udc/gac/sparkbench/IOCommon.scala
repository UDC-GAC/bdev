package es.udc.gac.sparkbench

import org.apache.hadoop.io.Text
import org.apache.spark.rdd.RDD
import org.apache.hadoop.io.{ LongWritable, NullWritable, Text }
import org.apache.hadoop.mapreduce.lib.input.KeyValueTextInputFormat
import org.apache.hadoop.mapreduce.lib.input.SequenceFileInputFormat
import org.apache.hadoop.mapreduce.lib.output.SequenceFileOutputFormat
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat
import org.apache.spark.SparkContext

class IOCommon(val sc: SparkContext) {

  def load(filename: String, input_format: String = "Sequence") = {

    input_format match {
      case "Text" =>
        sc.newAPIHadoopFile[LongWritable, Text, TextInputFormat](filename)
	  .map(x => (x._1.toString, x._2.toString))

      case "KeyValueText" =>
        sc.newAPIHadoopFile[Text, Text, KeyValueTextInputFormat](filename)
	  .map(x => (x._1.toString, x._2.toString))

      case "Sequence" =>
        sc.sequenceFile[Text, Text](filename)
	  .map(x => (x._1.toString, x._2.toString))

      case _ => throw new UnsupportedOperationException(s"Unknown input format: $input_format")
    }

  }

  def save[T1, T2](filename: String, data: RDD[(T1, T2)], output_format: String = "Sequence") = {

    val hadoop_data = data.map(x => (new Text(x._1.toString), new Text(x._2.toString)))
    
    output_format match {
      case "Text" =>
        hadoop_data.saveAsNewAPIHadoopFile[TextOutputFormat[Text, Text]](filename)
        
      case "KeyValueText" =>
        hadoop_data.saveAsNewAPIHadoopFile[TextOutputFormat[Text, Text]](filename)

      case "Sequence" =>
        hadoop_data.saveAsNewAPIHadoopFile[SequenceFileOutputFormat[Text, Text]](filename)

      case _ => throw new UnsupportedOperationException(s"Unknown output format: $output_format")
    }

  }
}
