module Bookmarks.FB.Bookmark exposing (Bookmark)

-- Firestoreで保持しているブックマークのデータ
-- こちらは読み出し系のためのデータ構造


type alias Bookmark =
    { id : String
    , title : String
    , description : String
    , url : String
    }
