module Bookmarks exposing (Bookmarks, map, new, size)

import Bookmark exposing (Bookmark)



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
