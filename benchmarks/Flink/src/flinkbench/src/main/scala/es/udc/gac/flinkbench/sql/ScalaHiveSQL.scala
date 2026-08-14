package es.udc.gac.flinkbench.sql

import org.apache.flink.table.api.{EnvironmentSettings, SqlDialect, TableEnvironment}
import org.apache.flink.table.catalog.hive.HiveCatalog
import org.apache.hadoop.hive.conf.HiveConf

object ScalaHiveSQL {

  def main(args: Array[String]): Unit = {

    if (args.length < 2) {
      System.err.println("Usage: ScalaHiveSQL <BENCH_NAME> <SQL_SCRIPT>")
      System.exit(1)
    }

    val bench_name = args(0)
    val sql_file = args(1)

    val bench_output_dir = System.getenv("BENCHMARK_OUTPUT_DIR")
    val hive_tmp_dir = System.getenv("HIVE_TMP_DIR")
    val tmp_dir = System.getenv("TMP_DIR")
    val hiveConf = new HiveConf()
    
    hiveConf.set("javax.jdo.option.ConnectionURL", s"jdbc:derby:;databaseName=$bench_output_dir/metastore_db_flink;create=true")
    hiveConf.set("hive.exec.scratchdir", hive_tmp_dir)
    hiveConf.set("hive.exec.local.scratchdir", s"$tmp_dir/hive")
    hiveConf.set("derby.stream.error.file", s"$bench_output_dir/derby_flink.log")
    hiveConf.set("hive.stats.autogather", "false")

    val settings = EnvironmentSettings.newInstance()
      .inBatchMode()
      .build()

    val tableEnv = TableEnvironment.create(settings)

    val catalogName = "myhive"
    val defaultDatabase = "default"
    val hiveVersion = "3.1.3"
    
    val hiveCatalog = new HiveCatalog(
      catalogName,
      defaultDatabase,
      null: String,
      hiveConf,
      hiveVersion,
      true // <-- allowEmbedded
    )
    
    tableEnv.registerCatalog(catalogName, hiveCatalog)
    tableEnv.useCatalog(catalogName)
    // Enable Hive dialect
    tableEnv.getConfig.setSqlDialect(SqlDialect.HIVE)

    val _sql = scala.io.Source.fromFile(sql_file).mkString
    _sql.split(';').foreach { statement =>
      val query = statement.trim
      if (query.nonEmpty) {        
        // .await() is required to wait for the INSERT to finish before continuing
        val tableResult = tableEnv.executeSql(query)
        tableResult.await() 
      }
    }

    println(s"[Flink Hive SQL] Benchmark $bench_name finished")
  }
}
