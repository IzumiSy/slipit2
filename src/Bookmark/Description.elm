module Bookmark.Description exposing
    ( Description
    , decode
    , encode
    , text
    )

import Html
import Json.Decode as Decode
import Json.Encode as Encode


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



-- encoder


encode : Description -> Encode.Value
encode (Description value) =
    Encode.string value
