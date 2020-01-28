ThisBuild / scalaVersion     := "2.13.1"
ThisBuild / version          := "0.1.0-SNAPSHOT"
ThisBuild / organization     := "com.adamnfish"
ThisBuild / organizationName := "adamnfish"
ThisBuild / scalacOptions ++= Seq(
  "-deprecation",
  "-Xfatal-warnings",
  "-encoding", "UTF-8",
  "-target:jvm-1.8",
  "-Ywarn-dead-code"
)

val circeVersion = "0.12.3"
val commonDependencies = Seq(
  "com.gu" %% "content-api-client-default" % "15.9",
  "org.scalatest" %% "scalatest" % "3.1.0" % Test
)

lazy val root = (project in file("."))
  .settings(
    name := "hiy",
    libraryDependencies ++= commonDependencies
  )
  .aggregate(api, devserver)


lazy val api = (project in file("api"))
  .settings(
    name := "api",
    libraryDependencies ++= commonDependencies,
    libraryDependencies ++= Seq(
      "io.circe" %% "circe-core" % circeVersion,
      "io.circe" %% "circe-generic" % circeVersion,
      "io.circe" %% "circe-parser" % circeVersion,
      "com.amazonaws" % "aws-lambda-java-core" % "1.1.0",
      "com.amazonaws" % "aws-lambda-java-events" % "2.2.7"
    ),
    assemblyJarName in assembly := "hiy-api.jar",
    mainClass in assembly := Some("com.adamnfish.hiy.Main"),
  )


lazy val devserver = (project in file("devserver"))
  .settings(
    name := "devserver",
    libraryDependencies ++= commonDependencies,
    libraryDependencies ++= Seq(
      "io.javalin" % "javalin" % "3.6.0",
      "com.lihaoyi" %% "requests" % "0.2.0",
      "org.slf4j" % "slf4j-simple" % "1.8.0-beta4",
      "org.slf4j" % "slf4j-api" % "1.8.0-beta4"
    ),
    fork in run := true,
    connectInput in run := true,
    outputStrategy := Some(StdoutOutput)
  )
  .dependsOn(api)
