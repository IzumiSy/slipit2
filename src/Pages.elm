module Pages exposing (viewLink)

import Html exposing (Html, a, text)
import Html.Attributes exposing (href)


viewLink : String -> String -> Html msg
viewLink path title =
    a [ href ("#/" ++ path) ] [ text title ]
