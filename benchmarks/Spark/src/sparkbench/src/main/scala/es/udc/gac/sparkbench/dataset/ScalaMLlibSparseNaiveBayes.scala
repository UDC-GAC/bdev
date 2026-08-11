package es.udc.gac.sparkbench.dataset

import org.apache.spark.mllib.linalg.Vectors
import scopt.OptionParser

import org.apache.spark.ml.classification.NaiveBayes
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions._
import es.udc.gac.sparkbench.IOCommon

/*
 * Adapted from spark's examples
 */
object ScalaMLlibSparseNaiveBayes {

  case class Params(
      input: String = null,
      output: String = null,
      numFeatures: Int = -1,
      lambda: Double = 1.0)

  def main(args: Array[String]) {
    val defaultParams = Params()

    val parser = new OptionParser[Params]("ScalaMLlibSparseNaiveBayes") {
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

    val session = SparkSession.builder().appName("SparkBench ScalaMLlibSparseNaiveBayes").getOrCreate()
    import session.implicits._

    val sc = session.sparkContext

    // Load data
    val io = new IOCommon()

    val data = io.load_dataset(params.input, session, "Sequence")

    val wordCount = data.
      flatMap{ case(key, value) => value.split(" ")}.
      groupBy($"value").
      agg(count("*").as("count")).
      select($"value".as("word"), $"count").
      as[(String, Long)]

    val wordSum = wordCount.
      map(e => e._2).
      reduce((e1, e2) => (e1 + e2))

    val wordDict = wordCount.
      rdd.
      zipWithIndex().
      map{case ((key, count), index) => (key, (index.toInt, count.toDouble / wordSum)) }.
      collectAsMap()

    val sharedWordDict = sc.broadcast(wordDict)

    val computeDocVectorUdf = udf((doc: String) => 
        doc.split(" ").map(x => sharedWordDict.value.get(x).get) //map to word index: freq
          .groupBy(_._1) // combine freq with same word
          .map { case (k, v) => (k, v.map(_._2).sum)}
          .toList.sortBy(_._1).unzip)


    val extractIndicesUdf = udf((vectorUdf: (Array[Int], Array[Double])) => vectorUdf._1.toArray)
    val exctractValuesUdf = udf((vectorUdf: (Array[Int], Array[Double])) => vectorUdf._2.toArray)
    val computeLabelUdf = udf((docKey: String) => docKey.substring(6).head.toDouble)


    val vector = data.
      withColumn("docVector", computeDocVectorUdf($"value")).
      withColumn("indices", extractIndicesUdf($"docVector")).
      withColumn("values", exctractValuesUdf($"docVector")).
      withColumn("label", computeLabelUdf($"index")).
      select($"label",$"indices", $"values").
      as[(Double, Array[Int], Array[Double])]

    val d = if (params.numFeatures > 0){
      params.numFeatures
    } else {
      vector.rdd.
        map{case (a,b,c) => b.lastOption.getOrElse(0)}.
        reduce((a,b) => Math.max(a,b)) + 1
    }

    val examples = vector.map{ case (label, indices, values) =>
      (label.toDouble, Vectors.sparse(d, indices.toArray, values.toArray).asML)
    }.select($"_1".as("label"), $"_2".as("vector")).
    as[(Double, org.apache.spark.ml.linalg.Vector)]


    examples.cache()

    val splits = examples.randomSplit(Array(0.8, 0.2))
    val training = splits(0)
    val test = splits(1)

    val numTraining = training.count()
    val numTest = test.count()

    println(s"numTraining = $numTraining, numTest = $numTest.")

    val model = new NaiveBayes().
      setModelType("multinomial").
      setSmoothing(params.lambda).
      fit(training.withColumnRenamed("vector", "features"))

    val labelsTable = sc.broadcast(examples.select($"label").distinct().as[Double].collect().sorted)
    val processLabelUdf = udf((label: Double) => labelsTable.value(label.toInt))

    val predictionAndLabel = model.
      transform(test.withColumnRenamed("vector", "features")).
      withColumn("prediction", processLabelUdf($"prediction")).
      select($"label", $"prediction").
      as[(Double, Double)]


    val resultCheck = udf((label: Double, prediction: Double) => label == prediction)
    val accuracy = predictionAndLabel.
      filter(resultCheck($"label", $"prediction")).
      count.toDouble / numTest

    println(s"Test accuracy = $accuracy.")

    model.save(params.output)
    //sc.stop()
  }
}
