module Model exposing (..)


import Http
import Json.Decode
import Json.Decode.Pipeline exposing (required)


-- Can be useful to change this while developing to get hot reloading
root : String
--root = "/"
root = "http://localhost:7000/"


type Model
    = Query String
    | Searching String
    | Result String SearchResult
    | SearchError String String

type Msg
    = TypeQuery String
    | SearchResponse ( Result Http.Error SearchResult )
    | Search
    | Navigate String


type alias Subject =
    { name: String
    , section: String
    , path: String
    }

type alias Contributor =
    { name : String
    , profileImgSrc : Maybe String
    , path : String
    }

type alias Article =
    { title : String
    , age : Maybe Int
    , path : String
    }

type alias SearchResult =
    { subjects : List Subject
    , contributors : List Contributor
    , articles : List Article
    }

subjectDecoder : Json.Decode.Decoder Subject
subjectDecoder =
    Json.Decode.succeed Subject
        |> required "name" Json.Decode.string
        |> required "section" Json.Decode.string
        |> required "path" Json.Decode.string

contributorDecoder : Json.Decode.Decoder Contributor
contributorDecoder =
    Json.Decode.succeed Contributor
        |> required "name" Json.Decode.string
        |> required "profileImgSrc" (Json.Decode.nullable Json.Decode.string)
        |> required "path" Json.Decode.string

articleDecoder : Json.Decode.Decoder Article
articleDecoder =
    Json.Decode.succeed Article
        |> required "title" Json.Decode.string
        |> required "age" (Json.Decode.nullable Json.Decode.int)
        |> required "path" Json.Decode.string

searchResultDecoder : Json.Decode.Decoder SearchResult
searchResultDecoder =
    Json.Decode.succeed SearchResult
        |> required "subjects" (Json.Decode.list subjectDecoder)
        |> required "contributors" (Json.Decode.list contributorDecoder)
        |> required "articles" (Json.Decode.list articleDecoder)


performSearch : String -> Cmd Msg
performSearch query =
    Http.get
        { url = root ++ "api/" ++ query
        , expect = Http.expectJson SearchResponse searchResultDecoder
        }
