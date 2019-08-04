module Pages.NewBookmark.FB exposing (Bookmark)

-- Firestoreで保持しているブックマークのデータ
-- こちらは作成系で使われる構造


type alias Bookmark =
    { title : String
    , description : String
    , url : String
    }
