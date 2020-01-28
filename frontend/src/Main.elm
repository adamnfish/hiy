module Main exposing (..)

import Browser
import Html exposing (Html, text, div, h1, img)
import Html.Attributes exposing (src)
import Model exposing (..)
import View exposing (view)
import Ports exposing (..)


---- MODEL ----



init : ( Model, Cmd Msg )
init =
    ( Query "", Cmd.none )



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model of
        Query query ->
            case msg of
                TypeQuery newQuery ->
                    ( Query newQuery, Cmd.none )

                Search ->
                    ( Searching query, performSearch query )

                SearchResponse (Ok searchResult) ->
                    ( Result query searchResult, Cmd.none )

                SearchResponse (Err err) ->
                    ( SearchError query "Error querying", Cmd.none )

                Navigate path ->
                    ( model, navigate path )


        Result query searchResult ->
            case msg of
                TypeQuery newQuery ->
                    ( Result newQuery searchResult, Cmd.none )

                Search ->
                    ( Searching query, performSearch query )

                SearchResponse (Ok newSearchResult) ->
                    ( Result query newSearchResult, Cmd.none )

                SearchResponse (Err err) ->
                    ( SearchError query "Error querying", Cmd.none )

                Navigate path ->
                     ( model, navigate path )


        Searching query ->
            case msg of
                TypeQuery newQuery ->
                    ( Searching newQuery, Cmd.none )

                Search ->
                    ( Searching query, performSearch query )

                SearchResponse (Ok searchResult) ->
                    ( Result query searchResult, Cmd.none )

                SearchResponse (Err err) ->
                    ( SearchError query "Error querying", Cmd.none )

                Navigate path ->
                    ( model, navigate path )


        SearchError query _ ->
            case msg of
                TypeQuery newQuery ->
                    ( Searching newQuery, Cmd.none )

                Search ->
                    ( Searching query, performSearch query )

                SearchResponse (Ok searchResult) ->
                    ( Result query searchResult, Cmd.none )

                SearchResponse (Err err) ->
                    ( SearchError query "Error querying", Cmd.none )

                Navigate path ->
                    ( model, navigate path )





---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
