package com.adamnfish.hiy.models


case class CapiContributor(
  id: String,
  webTitle: String,
  bylineImageUrl: Option[String],
  webUrl: String,
)

case class CapiTag(
  id: String,
  `type`: String,
  sectionName: Option[String],
  webTitle: String,
  webUrl: String
)

case class Subject(
  name: String,
  section: String,
  path: String
)
case class Contributor(
  name: String,
  profileImgSrc: Option[String],
  path: String
)
case class Article(
  title: String,
  age: Option[Long],
  path: String
)

sealed trait ApiResponse extends Product with Serializable
case class Status(
  status: String
) extends ApiResponse
case class ApiError(
  error: String,
  description: String
) extends ApiResponse
case class SearchResult(
  subjects: List[Subject],
  contributors: List[Contributor],
  articles: List[Article]
) extends ApiResponse
object ApiResponse
