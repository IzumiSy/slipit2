module Bookmark.Url exposing
    ( Url
    , decode
    , href
    , text
    )

import Html
import Html.Attributes as Attributes
import Json.Decode as Decode


type Url
    = Url String



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
