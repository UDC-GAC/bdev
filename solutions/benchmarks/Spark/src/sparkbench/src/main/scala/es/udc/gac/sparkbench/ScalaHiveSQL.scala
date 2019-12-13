package es.udc.gac.sparkbench

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.sql.hive.HiveContext

/*
 * Adapted from HiBench
 */
object ScalaHiveSQL{

  def main(args: Array[String]) {

    if (args.length < 2) {
      System.err.println("Usage: ScalaHiveSQL <BENCH_NAME> <SQL_SCRIPT>")
      System.exit(1)
    }

    val bench_name = args(0)
    val sql_file = args(1)
    val sparkConf = new SparkConf().setAppName("SparkBench ScalaHiveSQL " + bench_name)

    /* Hive configuration */
    val bench_output_dir = System.getenv("BENCHMARK_OUTPUT_DIR")
    val hive_tmp_dir = System.getenv("HIVE_TMP_DIR")
    val tmp_dir = System.getenv("TMP_DIR")
    System.setProperty("javax.jdo.option.ConnectionURL", "jdbc:derby:;databaseName="+bench_output_dir+"/metastore_db;create=true")
    System.setProperty("hive.exec.scratchdir", hive_tmp_dir);
    System.setProperty("hive.exec.local.scratchdir", tmp_dir+"/hive");
    System.setProperty("hive.input.format", "org.apache.hadoop.hive.ql.io.HiveInputFormat");
    System.setProperty("hive.stats.autogather", "false");
    System.setProperty("derby.stream.error.file", bench_output_dir+"/derby.log")
    System.setProperty("hive.log.dir", tmp_dir+"/hive")

    val sc = new SparkContext(sparkConf)
    val hiveContext = new HiveContext(sc)

    val _sql = scala.io.Source.fromFile(sql_file).mkString
    _sql.split(';').foreach { x =>
      if (x.trim.nonEmpty)
        hiveContext.sql(x)
    }

    //sc.stop()
  }
}
