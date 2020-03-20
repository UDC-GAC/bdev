name := "sparkbench"
version := "2.2"
val sparkVersion = "2.2.0"
scalaVersion := "2.11.12"

libraryDependencies ++= Seq(
"org.apache.spark" %% "spark-core" % sparkVersion % "provided",
"org.apache.spark" %% "spark-graphx" % sparkVersion % "provided",
"org.apache.spark" %% "spark-mllib" % sparkVersion % "provided",
"org.apache.spark" %% "spark-hive" % sparkVersion % "provided",
"org.apache.hadoop" % "hadoop-mapreduce-examples" % "2.7.0",
"org.apache.mahout" % "mahout-mr" % "0.11.2",
"com.github.scopt" %% "scopt" % "3.7.1"
)

assemblyShadeRules in assembly := Seq(
  ShadeRule.rename("com.github.scopt.**" -> "shadeSCOPT.@1").inAll
)

assemblyJarName in assembly := s"${name.value}-${version.value}_${scalaBinaryVersion.value}.jar"

assemblyOption in assembly := (assemblyOption in assembly).value.copy(includeScala = false)

assemblyMergeStrategy in assembly := {
  case PathList("org","aopalliance", xs @ _*) => MergeStrategy.last
  case PathList("javax", "inject", xs @ _*) => MergeStrategy.last
  case PathList("javax", "servlet", xs @ _*) => MergeStrategy.last
  case PathList("javax", "activation", xs @ _*) => MergeStrategy.last
  case PathList("javax", "xml", xs @ _*) => MergeStrategy.last
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
