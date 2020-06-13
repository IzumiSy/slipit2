module Bookmark.Description exposing
    ( Description
    , decode
    , text
    )

import Html
import Json.Decode as Decode


type Description
    = Description String



-- view


text : Description -> Html.Html msg
text (Description value) =
    Html.text value



-- decoder


decode : Decode.Decoder Description
decode =
    Decode.andThen (Decode.succeed << Description) Decode.string
