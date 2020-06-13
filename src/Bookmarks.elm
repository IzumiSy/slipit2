module Bookmarks exposing (Bookmarks, decode, map, size)

import Bookmark exposing (Bookmark)
import Json.Decode as Decode



-- Bookmarkのコレクションを表現する型


type Bookmarks
    = Bookmarks (List Bookmark)


map : (Bookmark -> a) -> Bookmarks -> List a
map cb (Bookmarks bookmarks) =
    List.map cb bookmarks


size : Bookmarks -> Int
size (Bookmarks bookmarks) =
    List.length bookmarks



-- encoder


decode : Decode.Decoder Bookmarks
decode =
    Bookmark.decoder
        |> Decode.list
        |> Decode.andThen (Decode.succeed << Bookmarks)
