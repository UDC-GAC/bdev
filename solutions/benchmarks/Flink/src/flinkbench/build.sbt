name := "flinkbench"
version := "1.8"
val flinkVersion = "1.8.0"
crossScalaVersions := Seq("2.11.12", "2.12.10")

libraryDependencies ++= Seq(
"org.apache.flink" %% "flink-scala" % flinkVersion % "provided",
"org.apache.flink" %% "flink-gelly-scala" % flinkVersion % "provided",
"org.apache.flink" %% "flink-hadoop-compatibility" % flinkVersion % "provided",
"org.apache.mahout" % "mahout-mr" % "0.11.2"
)

assemblyShadeRules in assembly := Seq(
  ShadeRule.rename("org.apache.commons.cli.**" -> "shadeApacheCommonsCLI.@1").inAll
)

assemblyJarName in assembly := s"${name.value}-${version.value}_${scalaBinaryVersion.value}.jar"

assemblyOption in assembly := (assemblyOption in assembly).value.copy(includeScala = false)

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
