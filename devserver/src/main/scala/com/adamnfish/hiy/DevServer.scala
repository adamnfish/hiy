package com.adamnfish.hiy

import com.adamnfish.hiy.models.Serialisation._
import com.gu.contentapi.client.GuardianContentClient
import io.circe.syntax._
import io.javalin.Javalin
import io.javalin.http.Context


object DevServer {

  def main(args: Array[String]): Unit = {
    val capiKey = args.headOption
      .getOrElse(throw new RuntimeException("Provide CAPI key as CLI parameter"))
    val capiClient = GuardianContentClient(capiKey)

    val app = Javalin.create().start(7000)

    app.get("/api/*", apiHandler(capiClient))
    app.get("/*", staticHandler)

    Runtime.getRuntime.addShutdownHook(new Thread(() => {
      app.stop()
    }))
  }

  def apiHandler(capiClient: GuardianContentClient)(ctx: Context): Context = {
    val result = for {
      apiResponse <- Hiy.dispatch(ctx.path().stripPrefix("/api"), capiClient)
    } yield apiResponse.asJson.spaces2

    result.fold(
      { err =>
        ctx.result(err).status(500)
      },
      ctx.result
    )
    ctx.header("content-type", "application/json; charset=UTF-8")
    ctx.header("Access-Control-Allow-Origin", "*")
  }

  val allowedHeaders = Set(
    "content-type"
  )
  def staticHandler(ctx: Context): Context = {
    val r = requests.get(s"http://localhost:3000${ctx.path()}")
    ctx.result(r.text)
    r.headers.foreach { case (name, values) =>
      if (allowedHeaders.contains(name.toLowerCase)) {
        values.foreach(value => ctx.header(name, value))
      }
    }
    ctx
  }
}
