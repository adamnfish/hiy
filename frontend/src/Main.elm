module Main exposing (..)

import Browser
import Model exposing (..)
import View exposing (view)
import Ports exposing (..)




---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> ( Query "", Cmd.none )
        , update = update
        , subscriptions = always Sub.none
        }




---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TypeQuery newQuery ->
            case model of
                Searching _ ->
                    ( Query newQuery, Cmd.none )

                _ ->
                    ( Query newQuery, Cmd.none )


        SearchResponse (Ok searchResult) ->
            ( Result (currentQuery model) searchResult NotExpanded, Cmd.none )

        SearchResponse (Err err) ->
            ( SearchError (currentQuery model) "Error querying", Cmd.none )


        Search ->
            let
                query = currentQuery model
            in
            if String.length query >= 3 then
                ( Searching query, performSearch query )
            else
                ( Query query, Cmd.none )


        Navigate path ->
            ( model, navigate path )


        ExpandArticles ->
            case model of
                Result query searchResult _ ->
                    ( Result query searchResult ArticlesExpanded
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )


        ExpandContributors ->
            case model of
                Result query searchResult _ ->
                    ( Result query searchResult ContributorsExpanded
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )


        ExpandSubjects ->
            case model of
                Result query searchResult _ ->
                    ( Result query searchResult SubjectsExpanded
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        Unexpand ->
            case model of
                Result query searchResult _ ->
                    ( Result query searchResult NotExpanded
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

