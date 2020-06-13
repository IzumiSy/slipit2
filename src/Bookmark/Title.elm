module Bookmark.Title exposing
    ( Title
    , decode
    , text
    )

import Html
import Json.Decode as Decode


type Title
    = Title String



-- view


text : Title -> Html.Html msg
text (Title value) =
    Html.text value



-- decoder


decode : Decode.Decoder Title
decode =
    Decode.andThen (Decode.succeed << Title) Decode.string
