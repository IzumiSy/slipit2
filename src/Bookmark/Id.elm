module Bookmark.Id exposing (Id, decode)

import Json.Decode as Decode


type Id
    = Id String



-- decoder


decode : Decode.Decoder Id
decode =
    Decode.andThen (Decode.succeed << Id) Decode.string
