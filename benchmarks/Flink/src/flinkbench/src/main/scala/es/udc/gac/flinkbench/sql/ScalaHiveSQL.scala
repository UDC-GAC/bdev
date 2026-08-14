package es.udc.gac.flinkbench.sql

import org.apache.flink.table.api.{EnvironmentSettings, SqlDialect, TableEnvironment}
import org.apache.flink.table.catalog.hive.HiveCatalog

object ScalaFlinkHiveSQL {

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

    System.setProperty("javax.jdo.option.ConnectionURL", s"jdbc:derby:;databaseName=$bench_output_dir/metastore_db_flink;create=true")
    System.setProperty("hive.exec.scratchdir", hive_tmp_dir)
    System.setProperty("hive.exec.local.scratchdir", s"$tmp_dir/hive")
    System.setProperty("derby.stream.error.file", s"$bench_output_dir/derby_flink.log")
    System.setProperty("hive.stats.autogather", "false")

    val settings = EnvironmentSettings.newInstance()
      .inBatchMode()
      .build()

    val tableEnv = TableEnvironment.create(settings)

    val catalogName = "myhive"
    val defaultDatabase = "default"
     //hiveConfDir = null to take properties from System.getProperty/Classpath
    val hiveCatalog = new HiveCatalog(catalogName, defaultDatabase, null)
    
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
