package es.udc.gac.sparkbench.rdd

import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.storage.StorageLevel
import scopt.OptionParser

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.mllib.classification.NaiveBayes
import org.apache.hadoop.io.Text
import org.apache.spark.SparkContext._
import es.udc.gac.sparkbench.IOCommon

/*
 * Adapted from spark's examples
 */
object ScalaMLlibSparseNaiveBayes {

  case class Params(
      input: String = null,
      output: String = null,
      minPartitions: Int = 0,
      numFeatures: Int = -1,
      lambda: Double = 1.0)

  def main(args: Array[String]) {
    val defaultParams = Params()

    val parser = new OptionParser[Params]("ScalaMLlibSparseNaiveBayes") {
      opt[Int]("numPartitions")
        .text("min number of partitions")
        .action((x, c) => c.copy(minPartitions = x))
      opt[Int]("numFeatures")
        .text("number of features")
        .action((x, c) => c.copy(numFeatures = x))
      opt[Double]("lambda")
        .text(s"lambda (smoothing constant), default: ${defaultParams.lambda}")
        .action((x, c) => c.copy(lambda = x))
      arg[String]("<input>")
        .text("input path")
        .required()
        .action((x, c) => c.copy(input = x))
      arg[String]("<output>")
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
    val conf = new SparkConf().setAppName("SparkBench ScalaMLlibSparseNaiveBayes")
    val sc = new SparkContext(conf)

    val minPartitions =
      if (params.minPartitions > 0) params.minPartitions else sc.defaultMinPartitions

    // Load data
    val io = new IOCommon()
    val data = io.load(params.input, sc, "Sequence")

    // Generate vectors according to input documents
    val wordCount = data
      .flatMap{ case (key, doc) => doc.split(" ")}
      .map((_, 1L))
      .reduceByKey(_ + _)
    val wordSum = wordCount.map(_._2).reduce(_ + _)
    val wordDict = wordCount.zipWithIndex()
      .map{case ((key, count), index) => (key, (index.toInt, count.toDouble / wordSum)) }
      .collectAsMap()
    val sharedWordDict = sc.broadcast(wordDict)

    // for each document, generate vector based on word freq
    val vector = data.map { case (dockey, doc) =>
      val docVector = doc.split(" ").map(x => sharedWordDict.value(x)) //map to word index: freq
        .groupBy(_._1) // combine freq with same word
        .map { case (k, v) => (k, v.map(_._2).sum)}

      val (indices, values) = docVector.toList.sortBy(_._1).unzip
      val label = dockey.substring(6).head.toDouble
      (label, indices.toArray, values.toArray)
    }

    val d = if (params.numFeatures > 0){
      params.numFeatures
    } else {
      vector.persist(StorageLevel.MEMORY_ONLY)
      vector.map { case (label, indices, values) =>
        indices.lastOption.getOrElse(0)
      }.reduce(math.max) + 1
    }

    val examples = vector.map{ case (label, indices, values) =>
      LabeledPoint(label, Vectors.sparse(d, indices, values))
    }

    // Cache examples because it will be used in both training and evaluation.
    examples.cache()

    val splits = examples.randomSplit(Array(0.8, 0.2))
    val training = splits(0)
    val test = splits(1)

    val numTraining = training.count()
    val numTest = test.count()

    println(s"numTraining = $numTraining, numTest = $numTest.")

    val model = new NaiveBayes().setModelType("multinomial").setLambda(params.lambda).run(training)

    val prediction = model.predict(test.map(_.features))
    val predictionAndLabel = prediction.zip(test.map(_.label))
    val accuracy = predictionAndLabel.filter(x => x._1 == x._2).count().toDouble / numTest

    println(s"Test accuracy = $accuracy.")

    // Save model
    model.save(sc, params.output)

    //sc.stop()
  }
}
