module Bookmarks exposing (Bookmarks, map, new, size)

import Bookmark exposing (Bookmark)
import Bookmark.Description as Description
import Bookmark.Title as Title
import Bookmark.Url as Url
import Pages.FB.Bookmark as FBBookmark



-- Bookmarkのコレクションを表現する型


type Bookmarks
    = Bookmarks (List Bookmark)


new : List FBBookmark.Bookmark -> Bookmarks
new fbbookmarks =
    fbbookmarks
        |> List.map
            (\{ url, title, description } ->
                Bookmark.new
                    (Just url |> Url.new)
                    (title |> Title.new)
                    (description |> Description.new)
            )
        |> Bookmarks


map : (Bookmark -> a) -> Bookmarks -> List a
map cb (Bookmarks bookmarks) =
    List.map cb bookmarks


size : Bookmarks -> Int
size (Bookmarks bookmarks) =
    bookmarks |> List.length
