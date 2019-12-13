name := "sparkbench"

version := "1.5"

scalaVersion := "2.11.8"

libraryDependencies ++= Seq(
"org.apache.spark" %% "spark-core" % "2.2.0" % "provided",
"org.apache.spark" %% "spark-graphx" % "2.2.0" % "provided",
"org.apache.spark" %% "spark-mllib" % "2.2.0" % "provided",
"org.apache.spark" %% "spark-hive" % "2.2.0" % "provided",
"org.apache.hadoop" % "hadoop-mapreduce-examples" % "2.7.3",
"org.apache.mahout" % "mahout-core" % "0.9",
"org.apache.mahout" % "mahout-math" % "0.9",
"com.github.scopt" %% "scopt" % "3.4.0"
)

fork in run := true

resolvers += "Typesafe Public Repo" at "http://repo.typesafe.com/typesafe/releases"

resolvers += "sonatype-releases" at "https://oss.sonatype.org/content/repositories/releases/"

resolvers += Resolver.mavenLocal

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
