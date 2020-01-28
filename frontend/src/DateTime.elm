module DateTime exposing (..)


periodToStr : Int -> String
periodToStr ms =
    let
        years = ms // (1000 * 60 * 60 * 24 * 365)
        weeks = ms // (1000 * 60 * 60 * 24 * 7)
        days = ms // (1000 * 60 * 60 * 24)
        hours = ms // (1000 * 60 * 60 * 24)
        minutes = ms // (1000 * 60 * 60)
    in
    if years > 0 then
        String.fromInt years ++ "y"
    else if weeks > 0 then
        String.fromInt weeks ++ "w"
    else if days > 0 then
        String.fromInt days ++ "d"
    else if hours > 0 then
        String.fromInt hours ++ "h"
    else
        String.fromInt minutes ++ "m"
