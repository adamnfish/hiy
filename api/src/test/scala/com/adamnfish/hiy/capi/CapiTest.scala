package com.adamnfish.hiy.capi

import com.gu.contentapi.client.GuardianContentClient
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
