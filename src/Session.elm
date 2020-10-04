module Session exposing
    ( Msg(..)
    , Ops(..)
    , Session
    , Sessionable
    , UserData
    , init
    , isLoggedIn
    , isLoggingIn
    , mapAsLoggedIn
    , mapAsLoggingIn
    , mapAsNotLoggedIn
    , mapBookmarks
    , runOps
    , toNavKey
    , toUserData
    , update
    , updateWithMsg
    )

import Bookmarks exposing (Bookmarks)
import Browser.Navigation as Nav
import Toasts
import Url
import User as User



{- ページを横断してユーザーのログイン状態を保持する型

   現在のブックマーク一覧とログイン中のユーザーに関しては
   キャッシュして持っておき毎回ネットワーク越しの取得処理を行わない

-}


type alias UserData =
    { bookmarks : Bookmarks
    , currentUser : User.User
    , toasts : Toasts.Toasts
    }


type Session
    = NotLoggedIn Url.Url Nav.Key
    | LoggingIn Url.Url Nav.Key
    | LoggedIn Url.Url Nav.Key UserData


type alias Sessionable a =
    { a | session : Session }


init : Url.Url -> Nav.Key -> Session
init url navKey =
    NotLoggedIn url navKey


{-| アプリケーション全体の動きを制御するメッセージ
-}
type Ops
    = NoOp
    | AddToast Toasts.Toast
    | UnknownError String


runOps : Ops -> Session -> ( Session, Cmd Msg )
runOps ops session =
    case session of
        LoggedIn _ _ { toasts } ->
            case ops of
                AddToast toast ->
                    toasts
                        |> Toasts.add toast ToastsMsg
                        |> Tuple.mapFirst (\nextToasts -> mapToasts nextToasts session)

                _ ->
                    ( session, Cmd.none )

        _ ->
            ( session, Cmd.none )


type Msg
    = ToastsMsg Toasts.Msg


updateWithMsg : Msg -> Session -> ( Session, Cmd Msg )
updateWithMsg msg session =
    case session of
        LoggedIn _ _ { toasts } ->
            case msg of
                ToastsMsg subMsg ->
                    toasts
                        |> Toasts.update ToastsMsg subMsg
                        |> Tuple.mapFirst (\nextToasts -> mapToasts nextToasts session)

        _ ->
            ( session, Cmd.none )


update : Session -> Sessionable a -> Sessionable a
update newSession model =
    { model | session = newSession }


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


mapAsLoggedIn : Bookmarks -> User.User -> Session -> Session
mapAsLoggedIn bookmarks user session =
    case session of
        NotLoggedIn url navKey ->
            LoggedIn
                url
                navKey
                { bookmarks = bookmarks
                , currentUser = user
                , toasts = Toasts.init
                }

        LoggingIn url navKey ->
            LoggedIn
                url
                navKey
                { bookmarks = bookmarks
                , currentUser = user
                , toasts = Toasts.init
                }

        LoggedIn _ _ _ ->
            session


mapBookmarks : Bookmarks -> Session -> Session
mapBookmarks bookmarks session =
    case session of
        NotLoggedIn _ _ ->
            session

        LoggingIn _ _ ->
            session

        LoggedIn url navKey userData ->
            LoggedIn url navKey { userData | bookmarks = bookmarks }


mapToasts : Toasts.Toasts -> Session -> Session
mapToasts toasts session =
    case session of
        NotLoggedIn _ _ ->
            session

        LoggingIn _ _ ->
            session

        LoggedIn url navKey userData ->
            LoggedIn url navKey { userData | toasts = toasts }


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
