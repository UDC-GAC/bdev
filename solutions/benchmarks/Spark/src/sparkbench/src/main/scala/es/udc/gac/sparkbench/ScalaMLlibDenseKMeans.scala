package es.udc.gac.sparkbench

import org.apache.hadoop.io.LongWritable
import org.apache.log4j.{ Level, Logger }
import org.apache.mahout.math.VectorWritable
import org.apache.mahout.clustering.kmeans.Kluster
import org.apache.spark.mllib.clustering.VectorWithNorm
import org.apache.spark.mllib.clustering.KMeans
import org.apache.spark.mllib.clustering.KMeansModel
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.{ SparkConf, SparkContext }
import scopt.OptionParser
import org.apache.spark.SparkContext._

object ScalaMLlibDenseKMeans {

  case class Params(
    input: String = null,
    centers: String = null,
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
    val conf = new SparkConf().setAppName("SparkBench ScalaMLlibDenseKMeans")
    val sc = new SparkContext(conf)
    val io = new IOCommon(sc)

    val data = sc.sequenceFile[LongWritable, VectorWritable](params.input)
    val centers = sc.sequenceFile[LongWritable, Kluster](params.centers)

    val samples = data.map {
      case (k, v) =>
        var vector: Array[Double] = new Array[Double](v.get().size)
        for (i <- 0 until v.get().size)
          vector(i) = v.get().get(i)
        Vectors.dense(vector)
    }.cache()

    val initCenters = centers.map {
      case (k, v) =>
        val center = v.getCenter()
        var vector: Array[Double] = new Array[Double](center.size)
        for (i <- 0 until center.size)
          vector(i) = center.get(i)
        Vectors.dense(vector)
    }.collect()

    val initModel = new KMeansModel(initCenters)

    val numSamples = samples.count()
    val k = initModel.k

    println(s"numSamples = $numSamples, k = $k, iters = ${params.numIterations}, cd = ${params.convergenceDelta}")

    val model = new KMeans()
      .setK(k)
      .setEpsilon(params.convergenceDelta)
      .setMaxIterations(params.numIterations)
      .setInitialModel(initModel)
      .run(samples)

    val result = samples.map(p => (model.predict(p), p))

    io.save(params.output, result, "Text")
    //sc.stop()
  }
}
