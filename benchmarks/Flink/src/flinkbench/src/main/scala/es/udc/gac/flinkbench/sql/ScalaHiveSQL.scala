package es.udc.gac.flinkbench.sql

import org.apache.flink.table.api.{EnvironmentSettings, SqlDialect, TableEnvironment}
import org.apache.flink.table.catalog.hive.HiveCatalog
import org.apache.flink.table.module.hive.HiveModule
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
    hiveConf.set("hive.metastore.schema.verification", "false")
    hiveConf.set("datanucleus.schema.autoCreateAll", "true")
    
    val settings = EnvironmentSettings.newInstance()
      .inBatchMode()
      .build()

    val tableEnv = TableEnvironment.create(settings)

    val catalogName = "myhive"
    val defaultDatabase = "default"
    val hiveVersion = Option(System.getenv("FLINK_HIVE_VERSION"))
        .getOrElse("3.1.3")

    println(s"[Flink SQL] Hive version $hiveVersion")

    val constructor = classOf[HiveCatalog].getDeclaredConstructor(
      classOf[String],
      classOf[String],
      classOf[HiveConf],
      classOf[String],
      java.lang.Boolean.TYPE
    )
    constructor.setAccessible(true)

    val hiveCatalog = constructor.newInstance(
      catalogName,
      defaultDatabase,
      hiveConf,
      hiveVersion,
      java.lang.Boolean.TRUE
    ).asInstanceOf[HiveCatalog]
    
    tableEnv.registerCatalog(catalogName, hiveCatalog)
    tableEnv.useCatalog(catalogName)
    // Enable Hive dialect
    tableEnv.loadModule("hive", new HiveModule(hiveVersion))    
    tableEnv.useModules("hive", "core")
    tableEnv.getConfig.setSqlDialect(SqlDialect.HIVE)

    val _sql = scala.io.Source.fromFile(sql_file).mkString    
    _sql.split(';').foreach { statement =>
      val query = statement.trim
      if (query.nonEmpty) {
        if (query.toUpperCase.startsWith("SET ")) {
          val parts = query.substring(4).split("=", 2)
          if (parts.length == 2) {
            val key = parts(0).trim
            val value = parts(1).trim.replace("'", "").replace("\"", "")
            tableEnv.getConfig.getConfiguration.setString(key, value)
          }
        } else {
          println(s"[Flink SQL] Running: \n$query")
          // .await() is required to wait for the INSERT to finish before continuing
          val tableResult = tableEnv.executeSql(query)
          tableResult.await()
        }
        
      }
    }
    
    println(s"[Flink Hive SQL] Benchmark $bench_name finished")
  }
}
