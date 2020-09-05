module Bookmark.Title exposing
    ( Title
    , decode
    , text
    , unwrap
    )

import Html
import Json.Decode as Decode


type Title
    = Title String


unwrap : Title -> String
unwrap (Title value) =
    if String.isEmpty value then
        "(No title)"

    else
        value



-- view


text : Title -> Html.Html msg
text =
    Html.text << unwrap



-- decoder


decode : Decode.Decoder Title
decode =
    Decode.andThen (Decode.succeed << Title) Decode.string
