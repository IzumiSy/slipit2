module Bookmarks exposing (Bookmarks, decode, map, new, size)

import Bookmark exposing (Bookmark)
import Json.Decode as Decode



-- Bookmarkのコレクションを表現する型


type Bookmarks
    = Bookmarks (List Bookmark)


new : List Bookmark -> Bookmarks
new =
    Bookmarks


map : (Bookmark -> a) -> Bookmarks -> List a
map cb (Bookmarks bookmarks) =
    List.map cb bookmarks


size : Bookmarks -> Int
size (Bookmarks bookmarks) =
    bookmarks |> List.filter Bookmark.isValid |> List.length



-- encoder


decode : Decode.Decoder Bookmarks
decode =
    Decode.list Bookmark.decoder
        |> Decode.andThen (Decode.succeed << new)
