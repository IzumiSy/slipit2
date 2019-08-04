module Pages exposing
    ( onSubmitWithPrevented
    , viewLink
    )

import App.Model as Model
import Html exposing (Html, a, text)
import Html.Attributes exposing (href)
import Html.Events
import Json.Decode as Decode
import Session exposing (Session)



-- View


viewLink : String -> String -> Html msg
viewLink path title =
    a [ href path ] [ text title ]


onSubmitWithPrevented msg =
    Html.Events.custom "submit" (Decode.succeed { message = msg, stopPropagation = True, preventDefault = True })
