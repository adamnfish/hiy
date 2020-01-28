module View exposing (..)


import DateTime exposing (periodToStr)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Model exposing (Article, Contributor, Model(..), Msg(..), SearchResult, Subject)


view : Model -> Html Msg
view model =
    layout [] <| ui model


ui : Model -> Element Msg
ui model =
    case model of
        Query query ->
            column
                [ width fill
                ]
                [ searchEl query ]

        Searching query ->
            column
                [ width fill
                ]
                [ searchEl query
                , el
                    [ width fill
                    , padding 50
                    , Font.center
                    ]
                    <| text "Searching..."
                ]

        Result query searchResults ->
            column
                [ width fill
                ]
                [ searchEl query
                , resultsEl searchResults
                ]

        SearchError query error ->
            column
                [ width fill
                ]
                [ searchEl query ]


searchEl : String -> Element Msg
searchEl query =
    column
        [ width fill ]
        [ row
            [ width fill
            , spacing 0
            ]
            [ Input.text
                [ width <| fillPortion 8
                , padding 15
                , Border.width 1
                , Border.color <| rgb255 5 41 98
                , Border.rounded 0
                ]
                { onChange = TypeQuery
                , text = query
                , placeholder = Nothing
                , label = Input.labelHidden "Search"
                }
            , Input.button
                [ width <| maximum 100 <| fillPortion 3
                , padding 15
                , Background.color <| rgb255 5 41 98
                , Border.width 1
                , Border.color <| rgb255 5 41 98
                , Font.color <| rgb255 255 255 255
                ]
                { onPress = Just Search
                , label = text "Search"
                }
            ]
        ]


resultsEl : SearchResult -> Element Msg
resultsEl searchResult =
    let
        headerStyles =
            [ Background.color <| rgb255 220 220 220
            , padding 12
            , width fill
            , Font.alignLeft
            , Font.size 16
            ]
        articles =
            if List.length searchResult.articles > 0 then
                column
                    [ width fill ]
                    [ el
                        headerStyles
                        <| text "Articles"
                    , column
                        [ width fill
                        ]
                        <| List.map articleEl searchResult.articles
                    ]
            else
                none
        contributors =
            if List.length searchResult.contributors > 0 then
                column
                    [ width fill ]
                    [ el
                        headerStyles
                        <| text "Contributors"
                    , column
                        [ width fill
                        ]
                        <| List.map contributorEl searchResult.contributors
                    ]
            else
                none
        subjects =
            if List.length searchResult.subjects > 0 then
                column
                    [ width fill ]
                    [ el
                        headerStyles
                        <| text "Subjects"
                    , column
                        [ width fill
                        ]
                        <| List.map subjectEl searchResult.subjects
                    ]
            else
                none
    in
    column
        [ width fill ]
        [ articles
        , contributors
        , subjects
        ]

articleEl : Article -> Element Msg
articleEl article =
    row
        [ width fill
        , spacing 8
        , Events.onClick <| Navigate article.path
        , pointer
        , mouseOver resultHover
        , mouseDown resultHover
        ]
        [ el
            [ width <| px 40
            , paddingXY 12 8
            , Font.size 14
            , Font.alignLeft
            , lightFont
            ]
            <| text <| Maybe.withDefault "-" <| Maybe.map periodToStr article.age
        , Element.paragraph
            [ Font.alignLeft
            , Font.size 14
            , paddingEach { left = 0, top = 8, bottom = 8, right = 8 }
            ]
            [ text article.title ]
        ]

contributorEl : Contributor -> Element Msg
contributorEl contributor =
    let
        profile =
            Maybe.withDefault
                ( el
                    [ centerY
                    , width <| px 30
                    , height <| px 30
                    , Font.size 18
                    ]
                    <| el
                        [ centerY
                        , centerX
                        ]
                        <| text <| String.left 1 contributor.name
                )
                ( Maybe.map
                    (\src ->
                        image
                            [ width <| px 30
                            , Border.rounded 15
                            , clip
                            ]
                            { src = src
                            , description = contributor.name ++ " profile picture"
                            }
                    )
                    contributor.profileImgSrc
                )
    in
    row
        [ width fill
        , centerY
        , paddingEach { left = 6, right = 12, top = 8, bottom = 8 }
        , spacing 12
        , Events.onClick <| Navigate contributor.path
        , pointer
        , mouseOver resultHover
        , mouseDown resultHover
        ]
        [ profile
        , el
            [ Font.size 14 ]
            <| Element.text contributor.name
        ]

subjectEl : Subject -> Element Msg
subjectEl subject =
    column
        [ width fill
        , paddingXY 12 8
        , spacing 4
        , Events.onClick <| Navigate subject.path
        , pointer
        , mouseOver resultHover
        , mouseDown resultHover
        ]
        [ el
            [ Font.size 14 ]
            <| Element.text subject.name
        ,  el
            [ Font.size 12
            , lightFont
            ]
            <| Element.text subject.section
        ]


resultHover =
    [ Background.color <| rgb255 230 230 230
    ]


lightFont : Attr decorative msg
lightFont =
    Font.color
        <| rgb255 120 120 120
