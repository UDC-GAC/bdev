package es.udc.gac.sparkbench.rdd

import org.apache.hadoop.io.LongWritable
import org.apache.log4j.{ Level, Logger }
import org.apache.mahout.math.VectorWritable
import org.apache.mahout.clustering.kmeans.Kluster
import org.apache.spark.mllib.clustering.VectorWithNorm
import org.apache.spark.mllib.clustering.KMeans
import org.apache.spark.mllib.clustering.KMeansModel
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.{ SparkConf, SparkContext }
import org.apache.spark.broadcast.Broadcast
import scopt.OptionParser
import org.apache.spark.SparkContext._
import es.udc.gac.sparkbench.IOCommon

object ScalaNaiveDenseKMeans {

  case class Params(
    input: String = null,
    centers: String = null,
    output: String = null,
    numIterations: Int = 1,
    convergenceDelta: Double = 0.5)

  def main(args: Array[String]) {
    val defaultParams = Params()

    val parser = new OptionParser[Params]("ScalaNaiveDenseKMeans") {
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
    val conf = new SparkConf().setAppName("SparkBench ScalaNaiveDenseKMeans")
    val sc = new SparkContext(conf)
    val io = new IOCommon()

    val data = sc.sequenceFile[LongWritable, VectorWritable](params.input)
    val centers = sc.sequenceFile[LongWritable, Kluster](params.centers)

    val samples = data.map {
      case (k, v) =>
        var vector: Array[Double] = new Array[Double](v.get().size)
        for (i <- 0 until v.get().size)
          vector(i) = v.get().get(i)
        new Point(vector)
    }.cache()

    val initCenters = centers.map {
      case (k, v) =>
        val center = v.getCenter()
        var vector: Array[Double] = new Array[Double](center.size)
        for (i <- 0 until center.size)
          vector(i) = center.get(i)
        new Centroid(v.getId(), vector)
    }

    val numSamples = samples.count()
    val k = initCenters.count()
    val maxIterations = params.numIterations
    val converge_delta = params.convergenceDelta

    println(s"numSamples = $numSamples, k = $k, iters = ${params.numIterations}, cd = ${params.convergenceDelta}")

    val first = initCenters.first().array

    println(s"First $first")
    val n_dimensions = first.size

    var currentCentroids = initCenters
    var finished = false

    println(s"Dimensions $n_dimensions")

    var i = 0
    while (i < maxIterations && !finished) {
      println("Iteration " + i)

      val broadcasted_centroids = sc.broadcast(currentCentroids.collect())
      val newCentroids = samples
        .map(p => selectNearestCenterOpt(p, broadcasted_centroids))
        .foldByKey((new Point(new Array[Double](n_dimensions)), 0L)) { (p1, p2) => (p1._1.add(p2._1), p1._2 + p2._2) }
        .map { case (k, v) => new Centroid(k, v._1.div(v._2)) }

      val changed = currentCentroids.map(c => (c.id, c))
        .join(newCentroids.map(c => (c.id, c))).values.filter {
          case (centroid, newCentroid) =>
            centroid.squaredDistance(newCentroid) > converge_delta
        }

      currentCentroids = newCentroids

      if (changed.isEmpty()) {
        println("KMeans converged")
        finished = true
      }

      i = i + 1
    }

    val broadcasted_centroids = sc.broadcast(currentCentroids.collect())
    val clusteredPoints =
      samples.map(p => selectNearestCenter(p, broadcasted_centroids))

    io.save(params.output, clusteredPoints, sc, "Text")
    //sc.stop()
  }

  def selectNearestCenter(p: Point, centroids: Broadcast[Array[Centroid]]): (Int, Point) = {
    var minDistance: Double = Double.MaxValue
    var closestCentroidId: Int = -1
    for (centroid <- centroids.value) {
      val distance = p.euclideanDistance(centroid)
      if (distance < minDistance) {
        minDistance = distance
        closestCentroidId = centroid.id
      }
    }
    (closestCentroidId, p)
  }

  def selectNearestCenterOpt(p: Point, centroids: Broadcast[Array[Centroid]]): (Int, (Point, Long)) = {
    var minDistance: Double = Double.MaxValue
    var closestCentroidId: Int = -1
    for (centroid <- centroids.value) {
      val distance = p.euclideanDistance(centroid)
      if (distance < minDistance) {
        minDistance = distance
        closestCentroidId = centroid.id
      }
    }
    (closestCentroidId, (p, 1L))
  }

  /**
   * Common trait for operations supported by both points and centroids
   * Note: case class inheritance is not allowed in Scala
   */
  trait Coordinate extends Serializable {

    var array: Array[Double]

    def add(other: Coordinate): this.type = {
      for (i <- 0 until array.size)
        array(i) += other.array(i)
      this
    }

    def div(other: Long): this.type = {
      for (i <- 0 until array.size)
        array(i) /= other
      this
    }

    def squaredDistance(other: Coordinate): Double = {
      var cuad = 0.0
      for (i <- 0 until array.size)
        cuad += (array(i) - other.array(i)) * (array(i) - other.array(i))
      cuad
    }

    def euclideanDistance(other: Coordinate): Double = {
      Math.sqrt(squaredDistance(other))
    }

    def clear(): Unit = {
      array = null
    }

    override def toString: String =
      array.mkString("[", ",", "]")

  }

  /**
   * A simple n-dimensional point.
   */
  case class Point(var array: Array[Double]) extends Coordinate

  /**
   * A simple centroid, basically a point with an ID.
   */
  case class Centroid(var id: Int = 0, var array: Array[Double]) extends Coordinate {

    def this(id: Int, p: Point) {
      this(id, p.array)
    }

    override def toString: String =
      s"$id ${super.toString}"

  }
}
