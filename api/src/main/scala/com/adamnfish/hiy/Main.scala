package com.adamnfish.hiy

import java.io.PrintWriter

import com.adamnfish.hiy.models.{CapiContributor, CapiTag}
import com.adamnfish.hiy.models.Serialisation._

import scala.io.Source
import io.circe.parser.parse
import io.circe.syntax._


object Main {
  def main(args: Array[String]): Unit = {
    generateContributors()
    generateTags()
  }

  def generateContributors(): Unit = {
    val fullData = (1 to 22).foldLeft[List[CapiContributor]](Nil) { (acc, i) =>
      val jsonStr = Source.fromResource(s"contributors/$i.json").getLines.mkString("")
      val result = for {
        json <- parse(jsonStr)
        contributors <- json.as[List[CapiContributor]]
      } yield contributors

      val data = result.fold(
        { e =>
          throw new RuntimeException(s"Could not load source data in file $i", e)
        },
        identity
      )
      data ++: acc
    }
    val outputStr = fullData.asJson.noSpaces
    new PrintWriter("/tmp/contributors.json") { write(outputStr); close() }
  }

  def generateTags(): Unit = {
    val fullData = (1 to 22).foldLeft[List[CapiTag]](Nil) { (acc, i) =>
      val jsonStr = Source.fromResource(s"tags/$i.json").getLines.mkString("")
      val result = for {
        json <- parse(jsonStr)
        tags <- json.as[List[CapiTag]]
      } yield tags

      val data = result.fold(
        { e =>
          throw new RuntimeException(s"Could not load source data in file $i", e)
        },
        identity
      )
      data ++: acc
    }
    val outputStr = fullData.filter(t => t.`type` != "contributor").asJson.noSpaces
    new PrintWriter("/tmp/tags.json") { write(outputStr); close() }
  }
}
