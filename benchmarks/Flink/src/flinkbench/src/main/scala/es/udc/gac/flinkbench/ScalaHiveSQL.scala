package es.udc.gac.flinkbench.sql

import org.apache.flink.table.api.{EnvironmentSettings, SqlDialect, TableEnvironment}
import org.apache.flink.table.catalog.hive.HiveCatalog
import org.apache.hadoop.hive.conf.HiveConf

/*
 * Adapted for Apache Flink (Batch SQL on Hive)
 */
object ScalaFlinkHiveSQL {

  def main(args: Array[String]): Unit = {

    if (args.length < 2) {
      System.err.println("Usage: ScalaFlinkHiveSQL <BENCH_NAME> <SQL_SCRIPT>")
      System.exit(1)
    }

    val bench_name = args(0)
    val sql_file = args(1)

    val bench_output_dir = System.getenv("BENCHMARK_OUTPUT_DIR")
    val hive_tmp_dir = System.getenv("HIVE_TMP_DIR")
    val tmp_dir = System.getenv("TMP_DIR")

    // 1. Configuraciones de Hive / Derby embebido idénticas a las de Spark
    System.setProperty("javax.jdo.option.ConnectionURL", s"jdbc:derby:;databaseName=$bench_output_dir/metastore_db_flink;create=true")
    System.setProperty("hive.exec.scratchdir", hive_tmp_dir)
    System.setProperty("hive.exec.local.scratchdir", s"$tmp_dir/hive")
    System.setProperty("derby.stream.error.file", s"$bench_output_dir/derby_flink.log")
    System.setProperty("hive.stats.autogather", "false")

    // 2. Crear el TableEnvironment en modo BATCH
    val settings = EnvironmentSettings.newInstance()
      .inBatchMode()
      .build()

    val tableEnv = TableEnvironment.create(settings)

    // 3. Crear y registrar el HiveCatalog
    val catalogName = "myhive"
    val defaultDatabase = "default"
    // hiveConfDir = null para que tome las propiedades de System.getProperty / Classpath
    // Puedes especificar la versión de Hive del metastore si fuera necesario (ej. "3.1.3", "2.3.9")
    val hiveCatalog = new HiveCatalog(catalogName, defaultDatabase, null)
    
    tableEnv.registerCatalog(catalogName, hiveCatalog)
    tableEnv.useCatalog(catalogName)

    // 4. ACTIVAR EL DIALECTO DE HIVE (Fundamental para SerDe y SequenceFiles)
    tableEnv.getConfig.setSqlDialect(SqlDialect.HIVE)

    // 5. Lectura y ejecución de sentencias
    val _sql = scala.io.Source.fromFile(sql_file).mkString
    _sql.split(';').foreach { statement =>
      val query = statement.trim
      if (query.nonEmpty) {
        println(s"[Flink SQL] Ejecutando: $query")
        
        // En Flink, executeSql lanza el trabajo.
        // .await() es OBLIGATORIO para que espere a que termine el INSERT antes de seguir
        val tableResult = tableEnv.executeSql(query)
        tableResult.await() 
      }
    }

    println(s"[Flink SQL] Benchmark $bench_name finalizado con éxito.")
  }
}
