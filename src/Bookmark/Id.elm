module Bookmark.Id exposing
    ( Id
    , decode
    , encode
    )

import Json.Decode as Decode
import Json.Encode as Encode


type Id
    = Id String



-- decoder


decode : Decode.Decoder Id
decode =
    Decode.andThen (Decode.succeed << Id) Decode.string



-- encoder


encode : Id -> Encode.Value
encode (Id value) =
    Encode.string value
