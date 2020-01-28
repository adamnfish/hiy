package com.adamnfish.hiy

import com.adamnfish.hiy.models.Serialisation._
import com.amazonaws.services.lambda.runtime.Context
import com.amazonaws.services.lambda.runtime.events.{APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent}
import com.gu.contentapi.client.GuardianContentClient
import io.circe.syntax._

import scala.jdk.CollectionConverters._
import scala.util.Properties


class Lambda {
  def handleRequest(event: APIGatewayProxyRequestEvent, context: Context): APIGatewayProxyResponseEvent = {
    val capiKeyE = Properties.envOrNone("CAPI_KEY")
      .toRight("CAPI key is not present in the environment")

    val result = for {
      capiKey <- capiKeyE
      capiClient = GuardianContentClient(capiKey)
      apiResponse <- Hiy.dispatch(event.getPath.stripPrefix("/api"), capiClient)
    } yield {
      apiResponse.asJson.spaces2
    }

    result.fold(
      { err =>
        new APIGatewayProxyResponseEvent()
          .withStatusCode(200)
          .withHeaders(Map("content-type" -> "application/json").asJava)
          .withBody(err)
      },
      { body =>
        new APIGatewayProxyResponseEvent()
          .withStatusCode(200)
          .withHeaders(Map("content-type" -> "application/json").asJava)
          .withBody(body)
      }
    )
  }
}