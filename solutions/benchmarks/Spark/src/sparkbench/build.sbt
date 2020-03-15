name := "sparkbench"

version := "2.0"

scalaVersion := "2.11.8"

libraryDependencies ++= Seq(
"org.apache.spark" %% "spark-core" % "2.2.0" % "provided",
"org.apache.spark" %% "spark-graphx" % "2.2.0" % "provided",
"org.apache.spark" %% "spark-mllib" % "2.2.0" % "provided",
"org.apache.spark" %% "spark-hive" % "2.2.0" % "provided",
"org.apache.hadoop" % "hadoop-common" % "2.7.0" % "provided",
"org.apache.hadoop" % "hadoop-mapreduce-client-common" % "2.7.0" % "provided",
"org.apache.hadoop" % "hadoop-mapreduce-examples" % "2.7.0",
"org.apache.mahout" % "mahout-core" % "0.9",
"org.apache.mahout" % "mahout-math" % "0.9",
"com.github.scopt" %% "scopt" % "3.7.1"
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
