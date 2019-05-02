module Session exposing
    ( Session
    , init
    , isLoggedIn
    , mapAsLoggedIn
    , mapAsNotLoggedIn
    , toNavKey
    , update
    )

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


mapAsNotLoggedIn : Session -> Session
mapAsNotLoggedIn session =
    case session of
        NotLoggedIn _ _ ->
            session

        LoggingIn url navKey ->
            NotLoggedIn url navKey

        LoggedIn url navKey _ ->
            NotLoggedIn url navKey


toNavKey : Session -> Nav.Key
toNavKey session =
    case session of
        NotLoggedIn _ navKey ->
            navKey

        LoggingIn _ navKey ->
            navKey

        LoggedIn _ navKey _ ->
            navKey


isLoggedIn : Session -> Bool
isLoggedIn session =
    case session of
        NotLoggedIn _ _ ->
            False

        LoggingIn _ _ ->
            False

        LoggedIn _ _ _ ->
            True


type alias Sessionable a =
    { a | session : Session }


update : Session -> Sessionable a -> Sessionable a
update newSession model =
    { model | session = newSession }


init : Url.Url -> Nav.Key -> Session
init url navKey =
    NotLoggedIn url navKey
