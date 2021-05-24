package es.udc.gac.sparkbench.dataset

import org.apache.hadoop.io.LongWritable
import org.apache.log4j.{ Level, Logger }
import org.apache.mahout.math.VectorWritable
import org.apache.spark.ml.clustering.KMeans
import org.apache.spark.ml.linalg.Vectors
import scopt.OptionParser
import org.apache.spark.sql.SparkSession
import org.apache.spark.ml.linalg
import org.apache.spark.sql.functions._
import org.apache.spark.ml.clustering

object ScalaMLlibDenseKMeans {

  case class Params(
    input: String = null,
    output: String = null,
    numIterations: Int = 1,
    convergenceDelta: Double = 0.5)

  def main(args: Array[String]) {
    val defaultParams = Params()

    val parser = new OptionParser[Params]("ScalaMLlibDenseKMeans") {
      opt[Int]("numIterations")
        .text(s"number of iterations, default; ${defaultParams.numIterations}")
        .action((x, c) => c.copy(numIterations = x))
      opt[Double]("convergenceDelta")
        .text(s"convergence delta, default; ${defaultParams.convergenceDelta}")
        .action((x, c) => c.copy(convergenceDelta = x))
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

    // Initialize data
    val computeFeaturesUDF = udf((v: VectorWritable) => {

      var vector: Array[Double] = new Array[Double](v.get().size)

      for (i <- 0 until v.get().size)
        vector(i) = v.get().get(i)
      
      Vectors.dense(vector)

    })

    val data = sc.
      sequenceFile[LongWritable, VectorWritable](params.input).
      map{case (k: LongWritable, v: VectorWritable) => {
        var vector: Array[Double] = new Array[Double](v.get().size)

        for (i <- 0 until v.get().size)
          vector(i) = v.get().get(i)
        
        (k.get(), Vectors.dense(vector))
      }}.toDF().
      select($"_1".as("key"),$"_2".as("features")).
      as[(Long, linalg.Vector)]



    val KMeansModel = new KMeans().
      setTol(params.convergenceDelta).
      setMaxIter(params.numIterations).
      setFeaturesCol("features").
      setPredictionCol("cluster").
      setSeed(1L)

    val k = KMeansModel.getK
    val numSamples = data.count()

    println(s"numSamples = $numSamples, k = $k, iters = ${params.numIterations}, cd = ${params.convergenceDelta}")

    // Fit model and make predictions
    val predictions = KMeansModel.
      fit(data).
      transform(data).
      as[(Long, linalg.Vector, Int)]


    val combineResultUDF = udf((key: Long, cluster: Int) => key.toString() + ", " + cluster.toString())
    val result = predictions.
      withColumn("result", combineResultUDF($"key", $"cluster")).
      select($"result").
      as[String]


    result.write.text(params.output)

    //sc.stop()
  }
}
