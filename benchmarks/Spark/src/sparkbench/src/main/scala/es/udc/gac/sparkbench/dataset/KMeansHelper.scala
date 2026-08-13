package org.apache.spark.ml.clustering

import org.apache.spark.ml.linalg.Vector

object KMeansHelper {
  // Al estar dentro del mismo paquete, Scala sí nos deja usar el constructor privado
  def createInitialModel(centers: Array[Vector]): KMeansModel = {
    new KMeansModel("init_model", centers)
  }
}
