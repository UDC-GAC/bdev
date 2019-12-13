name := "flinkbench"

version := "1.0"

scalaVersion := "2.11.8"

libraryDependencies ++= Seq(
"org.apache.flink" % "flink-scala_2.11" % "1.4.0" % "provided",
"org.apache.flink" % "flink-clients_2.11" % "1.4.0" % "provided",
"org.apache.flink" % "flink-hadoop-compatibility_2.11" % "1.4.0",
"org.apache.flink" % "flink-gelly-scala_2.11" % "1.4.0",
"org.apache.flink" % "flink-gelly-examples_2.11" % "1.4.0",
"org.apache.mahout" % "mahout-core" % "0.9",
"org.apache.mahout" % "mahout-math" % "0.9",
"com.google.guava" % "guava" % "16.0"
)

fork in run := true

mergeStrategy in assembly <<= (mergeStrategy in assembly) { (old) =>
  {
    case PathList("javax", "servlet", xs @ _*) => MergeStrategy.last
    case PathList("javax", "activation", xs @ _*) => MergeStrategy.last
    case PathList("org", "apache", xs @ _*) => MergeStrategy.last
    case PathList("com", "google", xs @ _*) => MergeStrategy.last
    case PathList("com", "esotericsoftware", xs @ _*) => MergeStrategy.last
    case PathList("com", "codahale", xs @ _*) => MergeStrategy.last
    case PathList("com", "yammer", xs @ _*) => MergeStrategy.last
    case PathList("org", "xmlpull", xs @ _*) => MergeStrategy.last
    case PathList("org", "xpp3", xs @ _*) => MergeStrategy.last

    case "about.html" => MergeStrategy.rename
    case "META-INF/ECLIPSEF.RSA" => MergeStrategy.last
    case "META-INF/mailcap" => MergeStrategy.last
    case "META-INF/mimetypes.default" => MergeStrategy.last
    case "plugin.properties" => MergeStrategy.last
    case "log4j.properties" => MergeStrategy.last
    case x => old(x)
  }
}

