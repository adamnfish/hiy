module View exposing (..)


import DateTime exposing (periodToStr)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Html.Events
import Json.Decode as Decode
import Model exposing (Article, Contributor, ExpandedResult(..), Model(..), Msg(..), SearchResult, Subject)



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

        Result query searchResults expanded ->
            el
                [ width fill
                , below <| resultsEl searchResults expanded
                ]
                <| searchEl query

        SearchError query _ ->
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
            , spacing 4
            , padding 4
            , Background.color <| rgb255 5 41 98
            ]
            [ Input.text
                [ width <| fillPortion 8
                , padding 11
                , Border.width 1
                , Border.color <| rgb255 5 41 98
                , Border.rounded 0
                , onEnter Search
                , focused
                    [ Background.color <| rgb255 240 240 210 ]
                ]
                { onChange = TypeQuery
                , text = query
                , placeholder = Nothing
                , label = Input.labelHidden "Search"
                }
            , Input.button
                [ width <| maximum 100 <| fillPortion 3
                , padding 11
                , Background.color <| rgb255 255 229 0
                , Border.width 1
                , Border.color <| rgb255 5 41 98
                , Border.rounded 21
                , Font.color <| rgb255 5 41 98
                , focused
                    [ Border.innerGlow (rgb255 250 250 230) 6
                    ]
                ]
                { onPress = Just Search
                , label = text "Search"
                }
            ]
        ]


resultsEl : SearchResult -> ExpandedResult -> Element Msg
resultsEl searchResult expanded =
    let
        headerStyles =
            [ Background.color <| rgb255 220 220 220
            , paddingXY 12 16
            , width fill
            , Font.alignLeft
            , Font.size 16
            ]

        expandStyles =
            [ width fill
            , padding 12
            , Font.alignLeft
            , Font.size 14
            , Font.color <| rgb255 5 41 98
            , pointer
            ]

        expandThreshold = 4

        articles =
            if List.isEmpty searchResult.articles then
                none
            else
                let
                    count = List.length searchResult.articles
                    expandedEl =
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
                in
                case expanded of
                    ArticlesExpanded ->
                        el
                            [ width fill
                            , inFront
                                <| el
                                    [ width fill
                                    , padding 12
                                    , Events.onClick Unexpand
                                    , pointer
                                    , Font.alignRight
                                    ]
                                    <| text "×"
                            ]
                            expandedEl

                    NotExpanded ->
                        if count > expandThreshold then
                            column
                                [ width fill ]
                                [ el
                                    headerStyles
                                    <| text "Articles"
                                , column
                                    [ width fill
                                    ]
                                    <| List.map articleEl <| List.take expandThreshold searchResult.articles
                                , row
                                    (Events.onClick ExpandArticles :: expandStyles)
                                    [ el [] <| text "View "
                                    , el
                                        [ Font.bold ]
                                        <| text <| String.fromInt count
                                    , el [] <| text " articles ➔"
                                    ]
                                ]
                        else
                            expandedEl

                    _ ->
                        none

        contributors =
            if List.isEmpty searchResult.contributors then
                none
            else
                let
                    count = List.length searchResult.contributors
                    expandedEl =
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
                in
                case expanded of
                    ContributorsExpanded ->
                        el
                            [ width fill
                            , inFront
                                <| el
                                    [ width fill
                                    , padding 12
                                    , Events.onClick Unexpand
                                    , pointer
                                    , Font.alignRight
                                    ]
                                    <| text "×"
                            ]
                            expandedEl

                    NotExpanded ->
                        if count > expandThreshold then
                            column
                                [ width fill ]
                                [ el
                                    headerStyles
                                    <| text "Contributors"
                                , column
                                    [ width fill
                                    ]
                                    <| List.map contributorEl <| List.take expandThreshold searchResult.contributors
                                , row
                                    (Events.onClick ExpandContributors :: expandStyles)
                                    [ el [] <| text "View "
                                    , el
                                        [ Font.bold ]
                                        <| text <| String.fromInt count
                                    , el [] <| text " contributors ➔"
                                    ]
                                ]
                        else
                            expandedEl

                    _ ->
                        none

        subjects =
            if List.isEmpty searchResult.subjects then
                none
            else
                let
                    count = List.length searchResult.subjects
                    expandedEl =
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
                in
                case expanded of
                    SubjectsExpanded ->
                        el
                            [ width fill
                            , inFront
                                <| el
                                    [ width fill
                                    , padding 12
                                    , Events.onClick Unexpand
                                    , pointer
                                    , Font.alignRight
                                    ]
                                    <| text "×"
                            ]
                            expandedEl

                    NotExpanded ->
                        if count > expandThreshold then
                            column
                                [ width fill ]
                                [ el
                                    headerStyles
                                    <| text "Subjects"
                                , column
                                    [ width fill
                                    ]
                                    <| List.map subjectEl <| List.take expandThreshold searchResult.subjects
                                , row
                                    (Events.onClick ExpandSubjects :: expandStyles)
                                    [ el [] <| text "View "
                                    , el
                                        [ Font.bold ]
                                        <| text <| String.fromInt count
                                    , el [] <| text " subjects ➔"
                                    ]
                                ]
                        else
                            expandedEl

                    _ ->
                        none
    in
    column
        [ width fill ]
        [ subjects
        , contributors
        , articles
        ]


articleEl : Article -> Element Msg
articleEl article =
    row
        [ width fill
        , spacing 8
        , Events.onClick <| Navigate article.path
        , pointer
        , mouseOver resultHover
        ]
        [ el
            [ width <| px 40
            , paddingXY 12 8
            , Font.size 12
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
                    , Background.color <| rgb255 230 230 230
                    , Border.rounded 15
                    , clip
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


onEnter : msg -> Element.Attribute msg
onEnter msg =
    Element.htmlAttribute
        ( Html.Events.on "keyup"
            ( Decode.field "key" Decode.string
                |> Decode.andThen
                    (\key ->
                        if key == "Enter" then
                            Decode.succeed msg

                        else
                            Decode.fail "Not the enter key"
                    )
            )
        )
