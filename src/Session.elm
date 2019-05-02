module Session exposing (Session, init, mapAsLoggedIn, toNavKey)

import Bookmark exposing (Bookmark)
import Browser.Navigation as Nav
import Pages.FB.User as FBUser
import Url



-- ページを横断してユーザーのログイン状態を保持する型


type alias UserData =
    { bookmarks : List Bookmark
    , currentUser : FBUser.User
    }


type Session
    = NotLoggedIn Url.Url Nav.Key
    | LoggingIn Url.Url Nav.Key
    | LoggedIn Url.Url Nav.Key UserData


mapAsLoggedIn : List Bookmark -> FBUser.User -> Session -> Session
mapAsLoggedIn bookmarks user session =
    case session of
        NotLoggedIn url navKey ->
            LoggedIn url navKey { bookmarks = bookmarks, currentUser = user }

        LoggingIn url navKey ->
            LoggedIn url navKey { bookmarks = bookmarks, currentUser = user }

        LoggedIn _ _ _ ->
            session


toNavKey : Session -> Nav.Key
toNavKey session =
    case session of
        NotLoggedIn _ navKey ->
            navKey

        LoggingIn _ navKey ->
            navKey

        LoggedIn _ navKey _ ->
            navKey


init : Url.Url -> Nav.Key -> Session
init url navKey =
    NotLoggedIn url navKey
