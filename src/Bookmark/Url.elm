module Bookmark.Url exposing
    ( Url
    , decode
    , encode
    , href
    , text
    , unwrap
    )

import Html
import Html.Attributes as Attributes
import Json.Decode as Decode
import Json.Encode as Encode


type Url
    = Url String


unwrap : Url -> String
unwrap (Url value) =
    value



-- view


href : Url -> Html.Attribute msg
href (Url value) =
    Attributes.href value


text : Url -> Html.Html msg
text (Url value) =
    Html.text value



-- decoder


decode : Decode.Decoder Url
decode =
    Decode.andThen (Decode.succeed << Url) Decode.string



-- encoder


encode : Url -> Encode.Value
encode (Url value) =
    Encode.string value
