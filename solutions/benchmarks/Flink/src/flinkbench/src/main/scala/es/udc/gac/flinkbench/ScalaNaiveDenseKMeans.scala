package es.udc.gac.flinkbench

import org.apache.flink.hadoopcompatibility.scala.HadoopInputs
import org.apache.hadoop.io.LongWritable
import org.apache.mahout.math.VectorWritable
import org.apache.mahout.clustering.kmeans.Kluster
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat
import org.apache.hadoop.mapreduce.lib.input.SequenceFileInputFormat
import org.apache.flink.api.common.functions._
import org.apache.flink.api.java.functions.FunctionAnnotation.ForwardedFields
import org.apache.flink.api.java.utils.ParameterTool
import org.apache.flink.api.scala._
import org.apache.flink.configuration.Configuration

import org.apache.flink.util.Collector

import scala.collection.JavaConverters._

object ScalaNaiveDenseKMeans {

  def main(args: Array[String]) {

    // checking input parameters
    val params: ParameterTool = ParameterTool.fromArgs(args)

    if (params.getNumberOfParameters() < 5) {
    	println("Usage: ScalaNaiveDenseKMeans --input <path> --centers <path> --output <path> --numIterations <n> --convergenceDelta <cd>")
        System.exit(1)
    }

    // set up execution environment
    val env: ExecutionEnvironment = ExecutionEnvironment.getExecutionEnvironment
    env.getConfig.enableObjectReuse()

    val io = new IOCommon(env)

    val data: DataSet[(LongWritable, VectorWritable)] =
      env.createInput(HadoopInputs.readHadoopFile(new SequenceFileInputFormat[LongWritable, VectorWritable](),
        classOf[LongWritable], classOf[VectorWritable], params.get("input")))

    val centers: DataSet[(LongWritable, Kluster)] =
      env.createInput(HadoopInputs.readHadoopFile(new SequenceFileInputFormat[LongWritable, Kluster](),
        classOf[LongWritable], classOf[Kluster], params.get("centers")))

    val samples: DataSet[Point] = data.map {
      p =>
        val v = p._2
        var vector: Array[Double] = new Array[Double](v.get().size)
        for (i <- 0 until v.get().size)
		vector(i) = v.get().get(i)
        new Point(vector)
    }.rebalance()

    val initCenters: DataSet[Centroid] = centers.map {
      p =>
        val v = p._2
        val center = v.getCenter()
        var vector: Array[Double] = new Array[Double](center.size)
        for (i <- 0 until center.size)
		vector(i) = center.get(i)
        new Centroid(v.getId(), vector)
    }

    val numSamples = samples.count
    val k = initCenters.count
    val maxIterations = params.getInt("numIterations", 1)
    val converge_delta = params.getDouble("convergenceDelta", 0.5)

    println(s"numSamples = $numSamples, k = $k, iters = $maxIterations, cd = $converge_delta")

    val finalCentroids = initCenters.iterateWithTermination(maxIterations) {
      currentCentroids =>
        val newCentroids = samples
          .map(new SelectNearestCenterOpt).withBroadcastSet(currentCentroids, "centroids")
          .groupBy(0)
          .reduce { (p1, p2) => (p1._1, p1._2.add(p2._2), p1._3 + p2._3) }.withForwardedFields("_1")
          .map { x => new Centroid(x._1, x._2.div(x._3)) }.withForwardedFields("_1->id")

        val changed = currentCentroids.join(newCentroids).where(0).equalTo(0) {
          (centroid, newCentroid, out: Collector[Int]) => 
            if ( centroid.squaredDistance(newCentroid) > converge_delta ) 
              out.collect(1)
        }

        (newCentroids, changed)
    }

    val clusteredPoints: DataSet[(Int, Point)] =
      samples.map(new SelectNearestCenter).withBroadcastSet(finalCentroids, "centroids")

    io.save[Int, Point](params.get("output"), clusteredPoints, "Text")

    env.execute("FlinkBench ScalaNaiveDenseKMeans")
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
      array.mkString("{", ",", "}")

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

  /** Determines the closest cluster center for a data point. */
  @ForwardedFields(Array("*->_2"))
  final class SelectNearestCenter extends RichMapFunction[Point, (Int, Point)] {
    private var centroids: Traversable[Centroid] = null

    /** Reads the centroid values from a broadcast variable into a collection. */
    override def open(parameters: Configuration) {
      centroids = getRuntimeContext.getBroadcastVariable[Centroid]("centroids").asScala
    }

    def map(p: Point): (Int, Point) = {
      var minDistance: Double = Double.MaxValue
      var closestCentroidId: Int = -1
      for (centroid <- centroids) {
        val distance = p.euclideanDistance(centroid)
        if (distance < minDistance) {
          minDistance = distance
          closestCentroidId = centroid.id
        }
      }
      (closestCentroidId, p)
    }
  }

  /** Determines the closest cluster center for a data point. */
  @ForwardedFields(Array("*->_2"))
  final class SelectNearestCenterOpt extends RichMapFunction[Point, (Int, Point, Long)] {
    private var centroids: Traversable[Centroid] = null

    /** Reads the centroid values from a broadcast variable into a collection. */
    override def open(parameters: Configuration) {
      centroids = getRuntimeContext.getBroadcastVariable[Centroid]("centroids").asScala
    }

    def map(p: Point): (Int, Point, Long) = {
      var minDistance: Double = Double.MaxValue
      var closestCentroidId: Int = -1
      for (centroid <- centroids) {
        val distance = p.euclideanDistance(centroid)
        if (distance < minDistance) {
          minDistance = distance
          closestCentroidId = centroid.id
        }
      }
      (closestCentroidId, p, 1L)
    }
  }
}
