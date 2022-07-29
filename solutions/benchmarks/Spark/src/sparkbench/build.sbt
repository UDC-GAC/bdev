name := "sparkbench"
version := "3.2"
val sparkVersion = "3.2.0"
//scalaVersion := "2.12.16"
//crossScalaVersions := Seq("2.10.7", "2.11.12")
//crossScalaVersions := Seq("2.11.12", "2.12.16")
crossScalaVersions := Seq("2.12.16", "2.13.8")

libraryDependencies ++= Seq(
"org.apache.spark" %% "spark-core" % sparkVersion % "provided",
"org.apache.spark" %% "spark-graphx" % sparkVersion % "provided",
"org.apache.spark" %% "spark-mllib" % sparkVersion % "provided",
"org.apache.spark" %% "spark-hive" % sparkVersion % "provided",
"org.apache.hadoop" % "hadoop-mapreduce-examples" % "2.10.2" % "provided",
"org.apache.mahout" % "mahout-mr" % "0.11.2" excludeAll (
  ExclusionRule("org.apache.hadoop")
),
"com.github.scopt" %% "scopt" % "3.7.1"
)

assembly / assemblyShadeRules := Seq(
  ShadeRule.rename("com.github.scopt.**" -> "shadeSCOPT.@1").inAll
)

assembly / assemblyJarName := s"${name.value}-${version.value}_${scalaBinaryVersion.value}.jar"

assembly / assemblyOption := (assemblyOption in assembly).value.copy(includeScala = false)

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
  case "module-info.class" => MergeStrategy.discard
  case x =>
    val oldStrategy = (assembly / assemblyMergeStrategy).value
    oldStrategy(x)
}
