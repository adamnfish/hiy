package com.adamnfish.hiy.models

import io.circe.{Encoder, Decoder}
import io.circe.generic.semiauto.{deriveEncoder, deriveDecoder}


object Serialisation {
  implicit val statusEncoder: Encoder[Status] = deriveEncoder[Status]
  implicit val apiErrorEncoder: Encoder[ApiError] = deriveEncoder[ApiError]

  implicit val capiContributorEncoder: Encoder[CapiContributor] = deriveEncoder[CapiContributor]
  implicit val capiContributorDecoder: Decoder[CapiContributor] = deriveDecoder[CapiContributor]
  implicit val capiTagEncoder: Encoder[CapiTag] = deriveEncoder[CapiTag]
  implicit val capiTagDecoder: Decoder[CapiTag] = deriveDecoder[CapiTag]

  implicit val subjectEncoder: Encoder[Subject] = deriveEncoder[Subject]
  implicit val contributorEncoder: Encoder[Contributor] = deriveEncoder[Contributor]
  implicit val articleEncoder: Encoder[Article] = deriveEncoder[Article]
  implicit val searchResultEncoder: Encoder[SearchResult] = deriveEncoder[SearchResult]

  implicit val apiResponseEncoder: Encoder[ApiResponse] = Encoder.instance {
    case response: SearchResult =>
      searchResultEncoder.apply(response)
    case response: Status =>
      statusEncoder.apply(response)
    case response: ApiError =>
      apiErrorEncoder.apply(response)
  }
}
