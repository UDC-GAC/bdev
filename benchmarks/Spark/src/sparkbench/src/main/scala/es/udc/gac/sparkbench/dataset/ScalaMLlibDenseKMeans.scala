package es.udc.gac.sparkbench.dataset

import org.apache.hadoop.io.LongWritable
import org.apache.log4j.{ Level, Logger }
import org.apache.mahout.math.VectorWritable
import org.apache.mahout.clustering.kmeans.Kluster
import org.apache.spark.ml.clustering.KMeans
import org.apache.spark.ml.clustering.KMeansModel
import org.apache.spark.ml.linalg.Vectors
import org.apache.spark.ml.linalg.Vector
import scopt.OptionParser
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions._
import org.apache.spark.ml.clustering

object ScalaMLlibDenseKMeans {

  case class Params(
    input: String = null,
    centers: String = null,
    output: String = null,
    numIterations: Int = 1,
    convergenceDelta: Double = 0.5)

  def main(args: Array[String]) {
    val defaultParams = Params()
    val io = new IOCommon()
    
    val parser = new OptionParser[Params]("ScalaMLlibDenseKMeans") {
      opt[Int]("numIterations")
        .text(s"number of iterations, default; ${defaultParams.numIterations}")
        .action((x, c) => c.copy(numIterations = x))
      opt[Double]("convergenceDelta")
        .text(s"convergence delta, default; ${defaultParams.convergenceDelta}")
        .action((x, c) => c.copy(convergenceDelta = x))
      opt[String]("centers")
        .text("input paths to centers")
        .required()
        .action((x, c) => c.copy(centers = x))
      opt[String]("input")
        .text("input paths to samples")
        .required()
        .action((x, c) => c.copy(input = x))
      opt[String]("output")
        .text("output path")
        .required()
        .action((x, c) => c.copy(output = x))
    }

    parser.parse(args, defaultParams).map { params =>
      run(params)
    }.getOrElse {
      sys.exit(1)
    }
  }

  def run(params: Params) {

    val session = SparkSession.builder().appName("SparkBench ScalaMLlibDenseKMeans").getOrCreate()
    import session.implicits._

    val sc = session.sparkContext

    // Prepare input data
    val data = sc.
      sequenceFile[LongWritable, VectorWritable](params.input).map { 
        case (k: LongWritable, v: VectorWritable) => {
          var vector: Array[Double] = new Array[Double](v.get().size)
          for (i <- 0 until v.get().size) {
            vector(i) = v.get().get(i)
          }
          (k.get(), Vectors.dense(vector))
        }
      }.toDF().
      select($"_1".as("key"),$"_2".as("features")).
      as[(Long, Vector)]

    // Read centers as RDD
    val centersRDD = sc.sequenceFile[LongWritable, Kluster](params.centers)

    // Convert vectors to the moder API (spark.ml)
    val initCenters = centersRDD.map {
      case (k, v) =>
        val center = v.getCenter()
        val vector = new Array[Double](center.size)
        for (i <- 0 until center.size) {
          vector(i) = center.get(i)
        }
        Vectors.dense(vector)
    }.collect()

    val initModel = new KMeansModel("init_model", initCenters)
    val k = initCenters.length
    val numSamples = data.count()

    println(s"numSamples = $numSamples, k = $k, iters = ${params.numIterations}, cd = ${params.convergenceDelta}")

    val kmeansEstimator = new KMeans()
      .setK(k)
      .setInitialModel(initModel)
      .setTol(params.convergenceDelta)
      .setMaxIter(params.numIterations)
      .setFeaturesCol("features")
      .setPredictionCol("cluster")
      .setSeed(1L)
    
    // Fit model and make predictions
    val result = kmeansEstimator
      .fit(data)
      .transform(data)
      .as[(Long, linalg.Vector, Int)] // (key, features, cluster)
      .map(row => (row._3, row._2))   // row._3 is cluster, row._2 is features (Vector)
    
    io.save_dataset(params.output, result, session, "Text")
    session.stop()
  }
}
