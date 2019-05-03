module Pages.FB.Bookmark exposing (Bookmark)

-- Firestoreで保持しているブックマークのデータ


type alias Bookmark =
    { title : String
    , description : String
    , url : String
    }
