package com.adamnfish.hiy.capi

import java.io.PrintWriter

import com.adamnfish.hiy.models.{CapiContributor, CapiTag}
import com.adamnfish.hiy.models.Serialisation._
import com.gu.contentapi.client.GuardianContentClient
import org.scalatest.concurrent.ScalaFutures

import scala.concurrent.Await
import scala.concurrent.duration._
import scala.concurrent.ExecutionContext.Implicits.global
import scala.io.Source
import io.circe.parser.parse
import io.circe.syntax._
import org.scalatest.EitherValues


class CapiTest extends org.scalatest.FreeSpec with EitherValues {
  val capiClient = GuardianContentClient("xxx")

  "capi query checks" - {
//    "article" in {
//      val response = Await.result(Capi.contentSearch("corona", capiClient), 10.seconds)
//      println(s"Articles: ${response.results.map(_.id).mkString(",")}")
//    }

//    "contributor" in {
//      val response = Await.result(Capi.contributorSearch("adam", capiClient), 10.seconds)
//      println(s"Contributors: ${response.results.map(_.id).mkString(",")}")
//    }

//    "tag" in {
//      val response = Await.result(Capi.tagSearch("coronavirus", capiClient), 10.seconds)
//      println(s"Tags: ${response.results.map(_.id).mkString(",")}")
//    }
  }

  "subjects" - {
    "finds a matching tag" in {
      Capi.getAllTags().get
    }
  }

  "contributors" - {

  }
}
