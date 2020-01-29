package com.adamnfish.hiy.capi

import com.adamnfish.hiy.models.Serialisation._
import com.adamnfish.hiy.models._
import com.gu.contentapi.client.model.v1.{CapiDateTime, SearchResponse}
import com.gu.contentapi.client.{ContentApiClient, GuardianContentClient}
import io.circe.parser.parse

import scala.concurrent.{ExecutionContext, Future}
import scala.io.Source


object Capi {
  private[capi] def contentSearch(query: String, capiClient: GuardianContentClient)(implicit ec: ExecutionContext): Future[SearchResponse] = {
    val request = ContentApiClient.search.q(query).pageSize(40)
    capiClient.getResponse(request)
  }

  private[capi] def contentSearchToArticles(searchResponse: SearchResponse, now: Long): List[Article] = {
    searchResponse.results.map { content =>
      Article(
        content.webTitle,
        content.webPublicationDate.map(age(now)),
        content.id
      )
    }.toList
  }

  private[capi] def age(now: Long)(capiDateTime: CapiDateTime): Long = {
    (now * 1000) - capiDateTime.dateTime
  }

  def articleSearch(query: String, now: Long, capiClient: GuardianContentClient)(implicit ec: ExecutionContext): Future[List[Article]] = {
    contentSearch(query, capiClient).map(contentSearchToArticles(_, now))
  }

  def getAllContributors(): Either[String, List[CapiContributor]] = {
    val jsonStr = Source.fromResource(s"contributors.json").getLines.mkString("")
    val result = for {
      json <- parse(jsonStr)
      contributors <- json.as[List[CapiContributor]]
    } yield contributors

    result.left.map(err => err.getMessage)
  }

  def getAllTags(): Either[String,List[CapiTag]] = {
    val jsonStr = Source.fromResource(s"tags.json").getLines.mkString("")
    val result = for {
      json <- parse(jsonStr)
      tags <- json.as[List[CapiTag]]
    } yield tags

    result.left.map(err => err.getMessage)
  }

  def subjectSearch(query: String, capiTags: List[CapiTag]): List[Subject] = {
    capiTags
      .filter { capiTag =>
        capiTag.webTitle.toLowerCase().contains(query.toLowerCase())
      }
      .map { capiTag =>
        Subject(
          capiTag.webTitle,
          capiTag.sectionName.getOrElse(""),
          capiTag.id
        )
      }
  }

  def capiContributorToContributor(capiContributor: CapiContributor): Contributor = {
      Contributor(
        capiContributor.webTitle,
        capiContributor.bylineImageUrl,
        capiContributor.id
      )
  }

  def contributorSearch(query: String, capiContributors: List[CapiContributor]): List[Contributor] = {
    val maybeFirst =
      if (query.toLowerCase == "the hero inside yourself") {
        capiContributors.find(_.id == "profile/adam-fisher").map(capiContributorToContributor)
      } else {
        None
      }
    val matches = capiContributors
      .filter { capiContributor =>
        capiContributor.webTitle.toLowerCase().contains(query.toLowerCase())
      }
      .map(capiContributorToContributor)
    (maybeFirst ++ matches).toList
  }
}
