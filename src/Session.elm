module Session exposing
    ( Session
    , UserData
    , init
    , isLoggedIn
    , isLoggingIn
    , mapAsLoggedIn
    , mapAsLoggingIn
    , mapAsNotLoggedIn
    , toNavKey
    , toUserData
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


mapAsNotLoggedIn : Session -> Session
mapAsNotLoggedIn session =
    case session of
        NotLoggedIn _ _ ->
            session

        LoggingIn url navKey ->
            NotLoggedIn url navKey

        LoggedIn url navKey _ ->
            NotLoggedIn url navKey


mapAsLoggingIn : Session -> Session
mapAsLoggingIn session =
    case session of
        NotLoggedIn url navKey ->
            LoggingIn url navKey

        LoggingIn _ _ ->
            session

        LoggedIn url navKey _ ->
            LoggingIn url navKey


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


toUserData : Session -> Maybe UserData
toUserData session =
    case session of
        LoggedIn _ _ userData ->
            Just userData

        _ ->
            Nothing


isLoggedIn : Session -> Bool
isLoggedIn session =
    case session of
        NotLoggedIn _ _ ->
            False

        LoggingIn _ _ ->
            False

        LoggedIn _ _ _ ->
            True


isLoggingIn : Session -> Bool
isLoggingIn session =
    case session of
        NotLoggedIn _ _ ->
            False

        LoggingIn _ _ ->
            True

        LoggedIn _ _ _ ->
            False


type alias Sessionable a =
    { a | session : Session }


update : Session -> Sessionable a -> Sessionable a
update newSession model =
    { model | session = newSession }


init : Url.Url -> Nav.Key -> Session
init url navKey =
    NotLoggedIn url navKey
