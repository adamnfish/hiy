package com.adamnfish.hiy

import java.net.URLDecoder
import java.time.{LocalDateTime, ZoneId, ZoneOffset}

import com.adamnfish.hiy.capi.Capi
import com.adamnfish.hiy.models.{ApiError, ApiResponse, SearchResult, Status}
import com.gu.contentapi.client.GuardianContentClient

import scala.concurrent.{Await, Future}
import scala.concurrent.duration._
import scala.concurrent.ExecutionContext.Implicits.global


object Hiy {
  val SearchPath = "/(.*+)".r

  def dispatch(path: String, capiClient: GuardianContentClient): Either[String, ApiResponse] = {
    path match {
      case "/wake" =>
        wake()
      case SearchPath(rawQuery) =>
        val query = URLDecoder.decode(rawQuery, "UTF-8")
        val fResult = search(query, capiClient)
        Await.result(fResult, 5.seconds)
      case _ =>
        error("Not found")
    }
  }

  def search(query: String, capiClient: GuardianContentClient): Future[Either[String, SearchResult]] = {
    println(query)
    val now = LocalDateTime.now.toEpochSecond(ZoneOffset.UTC)
    Capi.articleSearch(query, now, capiClient).map { articles =>
      for {
        capiTags <- Capi.getAllTags()
        capiContributors <- Capi.getAllContributors()
      } yield {
        val subjects = Capi.subjectSearch(query, capiTags)
        val contributors = Capi.contributorSearch(query, capiContributors)
        SearchResult(subjects, contributors, articles)
      }
    }
  }

  def wake(): Either[String, Status] = {
    Right(Status("ok"))
  }

  def error(msg: String): Either[String, ApiError] = {
    Left(msg)
  }
}
