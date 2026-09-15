package es.udc.gac.sparkbench.sql

import org.apache.spark.SparkConf
import org.apache.spark.sql.SparkSession

/*
 * Adapted from HiBench
 */
object ScalaHiveSQL {

  def main(args: Array[String]) {

    if (args.length < 2) {
      System.err.println("Usage: ScalaHiveSQL <BENCH_NAME> <SQL_SCRIPT>")
      System.exit(1)
    }

    val bench_name = args(0)
    val sql_file = args(1)

    val bench_output_dir = System.getenv("BENCHMARK_OUTPUT_DIR")
    val hive_tmp_dir = System.getenv("HIVE_TMP_DIR")
    val tmp_dir = System.getenv("TMP_DIR")

    System.setProperty("derby.stream.error.file", "/dev/null")
    System.setProperty("javax.jdo.option.ConnectionURL", s"jdbc:derby:;databaseName=$bench_output_dir/metastore_db_spark;create=true")
    System.setProperty("hive.exec.scratchdir", hive_tmp_dir)
    System.setProperty("hive.exec.local.scratchdir", s"$tmp_dir/hive")
    System.setProperty("hive.stats.autogather", "false")
    System.setProperty("hive.log.dir", s"$tmp_dir/hive")
    System.setProperty("hive.metastore.schema.verification", "false")
    System.setProperty("datanucleus.schema.autoCreateAll", "true")
    System.setProperty("hive.input.format", "org.apache.hadoop.hive.ql.io.HiveInputFormat")

    val session = SparkSession.builder()
      .appName("SparkBench ScalaHiveSQL " + bench_name)
      .enableHiveSupport()
      .getOrCreate()

    val _sql = scala.io.Source.fromFile(sql_file).mkString
    _sql.split(';').foreach { x =>
      if (x.trim.nonEmpty)
        session.sql(x)
    }

    session.stop()
  }
}
