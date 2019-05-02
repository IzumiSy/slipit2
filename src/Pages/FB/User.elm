module Pages.FB.User exposing (User)

-- Firebase Auth が保持しているユーザーのデータ構造


type alias User =
    { uid : String
    , email : String
    , displayName : Maybe String
    }
