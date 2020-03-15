name := "flinkbench"

version := "1.8"

scalaVersion := "2.11.8"

libraryDependencies ++= Seq(
"org.apache.flink" %% "flink-scala" % "1.8.0" % "provided",
"org.apache.flink" %% "flink-hadoop-compatibility" % "1.8.0" % "provided",
"org.apache.flink" %% "flink-gelly-scala" % "1.8.0",
"org.apache.flink" %% "flink-gelly-examples" % "1.8.0",
"org.apache.hadoop" % "hadoop-common" % "2.7.0" % "provided",
"org.apache.hadoop" % "hadoop-mapreduce-client-common" % "2.7.0" % "provided",
"org.apache.mahout" % "mahout-core" % "0.9",
"org.apache.mahout" % "mahout-math" % "0.9",
"com.google.guava" % "guava" % "16.0"
)

assemblyMergeStrategy in assembly := {
  case PathList("org","aopalliance", xs @ _*) => MergeStrategy.last
  case PathList("javax", "inject", xs @ _*) => MergeStrategy.last
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
  case x =>
    val oldStrategy = (assemblyMergeStrategy in assembly).value
    oldStrategy(x)
}
