port module App exposing (init, main, subscriptions, update)

import App.Model as Model
import Bookmarks
import Browser
import Browser.Navigation as Nav
import Flag
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Pages.Bookmarks as Bookmarks
import Pages.Layout as Layout
import Pages.Loading as Loading
import Pages.NewBookmark as NewBookmark
import Pages.NewBookmark.Description as Description
import Pages.NewBookmark.Title as Title
import Pages.NewBookmark.Url as NewUrl
import Pages.NotFound as NotFound
import Pages.ResetPassword as ResetPassword
import Pages.SignIn as SignIn
import Pages.SignUp as SignUp
import Route
import Session exposing (Session)
import Update.Extra as ExUpdate
import Url
import User as User



-- model


type Model
    = WaitForLoggingIn Flag.Flag Session (Maybe Route.Routes)
    | NotFound Flag.Flag Session
    | SignIn SignIn.Model
    | SignUp SignUp.Model
    | ResetPassword ResetPassword.Model
    | Bookmarks Bookmarks.Model
    | NewBookmark NewBookmark.Model


init : Decode.Value -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init value url navKey =
    value
        |> Decode.decodeValue Flag.decode
        |> Result.withDefault Flag.empty
        |> (\flag ->
                ( WaitForLoggingIn flag (Session.init url navKey) (Route.fromUrl url)
                , Cmd.none
                )
           )


initPage : Model.Modelable a -> Maybe Route.Routes -> ( Model, Cmd Msg )
initPage { flag, session } maybeRoute =
    case maybeRoute of
        Nothing ->
            ( NotFound flag session, Cmd.none )

        Just Route.Bookmarks ->
            session
                |> Bookmarks.init flag
                |> Tuple.mapFirst Bookmarks
                |> ExUpdate.mapCmd GotBookmarksMsg

        Just (Route.NewBookmark maybeUrl maybeTitle maybeDescription) ->
            session
                |> NewBookmark.init
                    (maybeUrl |> Maybe.map NewUrl.new |> Maybe.withDefault NewUrl.empty)
                    (maybeTitle |> Maybe.map Title.new |> Maybe.withDefault Title.empty)
                    (maybeDescription |> Maybe.map Description.new |> Maybe.withDefault Description.empty)
                    flag
                |> Tuple.mapFirst NewBookmark
                |> ExUpdate.mapCmd GotNewBookmarkMsg

        Just Route.ResetPassword ->
            session
                |> ResetPassword.init flag
                |> Tuple.mapFirst ResetPassword
                |> ExUpdate.mapCmd GotResetPasswordMsg

        Just Route.SignIn ->
            session
                |> SignIn.init flag
                |> Tuple.mapFirst SignIn
                |> ExUpdate.mapCmd GotSignInMsg

        Just Route.SignUp ->
            session
                |> SignUp.init flag
                |> Tuple.mapFirst SignUp
                |> ExUpdate.mapCmd GotSignUpMsg


toSession : Model -> Session
toSession page =
    case page of
        WaitForLoggingIn _ session _ ->
            session

        NotFound _ session ->
            session

        SignIn model ->
            model.session

        SignUp model ->
            model.session

        ResetPassword model ->
            model.session

        Bookmarks model ->
            model.session

        NewBookmark model ->
            model.session


toFlag : Model -> Flag.Flag
toFlag page =
    case page of
        WaitForLoggingIn flag _ _ ->
            flag

        NotFound flag _ ->
            flag

        SignIn model ->
            model.flag

        SignUp model ->
            model.flag

        ResetPassword model ->
            model.flag

        Bookmarks model ->
            model.flag

        NewBookmark model ->
            model.flag



-- update


type Msg
    = LogsOut
    | LoggedOut ()
    | LoggedIn (Result Decode.Error InitialData)
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotSignInMsg SignIn.Msg
    | GotSignUpMsg SignUp.Msg
    | GotResetPasswordMsg ResetPassword.Msg
    | GotBookmarksMsg Bookmarks.Msg
    | GotNewBookmarkMsg NewBookmark.Msg
    | GotSessionMsg Session.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    logInGuard <|
        case ( msg, model ) of
            ( LinkClicked urlRequest, _ ) ->
                case urlRequest of
                    Browser.External href ->
                        ( model, Nav.load href )

                    Browser.Internal url ->
                        ( model
                        , Nav.pushUrl
                            (Session.toNavKey <| toSession model)
                            (Url.toString url)
                        )

            ( UrlChanged url, _ ) ->
                url
                    |> Route.fromUrl
                    |> initPage
                        { flag = toFlag model
                        , session = toSession model
                        }

            ( LogsOut, _ ) ->
                ( model, logsOut () )

            ( LoggedOut _, _ ) ->
                ( model
                    |> toSession
                    |> Session.mapAsNotLoggedIn
                    |> updateSession model
                , Cmd.none
                )

            ( LoggedIn result, WaitForLoggingIn _ session maybeNextRoute ) ->
                case result of
                    Ok { bookmarks, currentUser } ->
                        ( session
                            |> Session.mapAsLoggedIn bookmarks currentUser
                            |> updateSession model
                        , maybeNextRoute
                            |> Maybe.map (Route.replaceUrl (Session.toNavKey session))
                            |> Maybe.withDefault (Route.replaceUrl (Session.toNavKey session) Route.Bookmarks)
                        )

                    Err _ ->
                        ( model, Cmd.none )

            ( LoggedIn result, SignIn _ ) ->
                case result of
                    Ok { bookmarks, currentUser } ->
                        ( model
                            |> toSession
                            |> Session.mapAsLoggedIn bookmarks currentUser
                            |> updateSession model
                        , Route.replaceUrl
                            (model
                                |> toSession
                                |> Session.toNavKey
                            )
                            Route.Bookmarks
                        )

                    Err _ ->
                        ( model, Cmd.none )

            ( GotSignInMsg pageMsg, SignIn pageModel ) ->
                pageModel
                    |> SignIn.update pageMsg
                    |> pageUpdateWith SignIn GotSignInMsg

            ( GotSignUpMsg pageMsg, SignUp pageModel ) ->
                pageModel
                    |> SignUp.update pageMsg
                    |> pageUpdateWith SignUp GotSignUpMsg

            ( GotResetPasswordMsg pageMsg, ResetPassword pageModel ) ->
                pageModel
                    |> ResetPassword.update pageMsg
                    |> pageUpdateWith ResetPassword GotResetPasswordMsg

            ( GotBookmarksMsg pageMsg, Bookmarks pageModel ) ->
                pageModel
                    |> Bookmarks.update pageMsg
                    |> pageUpdateWith Bookmarks GotBookmarksMsg

            ( GotNewBookmarkMsg pageMsg, NewBookmark pageModel ) ->
                pageModel
                    |> NewBookmark.update pageMsg
                    |> appUpdateWith NewBookmark GotNewBookmarkMsg (toSession model)

            ( GotSessionMsg subMsg, page ) ->
                page
                    |> toSession
                    |> Session.updateWithMsg subMsg
                    |> Tuple.mapFirst (updateSession model)
                    |> ExUpdate.mapCmd GotSessionMsg

            ( _, _ ) ->
                ( model, Cmd.none )


logInGuard : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
logInGuard ( page, cmd ) =
    let
        toBookmarks =
            ( page, Route.replaceUrl (Session.toNavKey <| toSession page) Route.Bookmarks )
    in
    case ( page, Session.isLoggedIn <| toSession page ) of
        ( SignIn _, True ) ->
            toBookmarks

        ( SignUp _, True ) ->
            toBookmarks

        ( ResetPassword _, True ) ->
            toBookmarks

        ( SignIn _, False ) ->
            -- すでにサインインの画面にいる場合には画面遷移のループが発生しないよう何もしないでおく
            ( page, cmd )

        ( _, False ) ->
            ( page, Route.replaceUrl (Session.toNavKey <| toSession page) Route.SignIn )

        ( _, _ ) ->
            ( page, cmd )


{-| 特定のpageモジュールに閉じたupdateに対して使われる更新ヘルパ関数
-}
pageUpdateWith :
    (Model.Modelable pageModel -> model)
    -> (pageMsg -> Msg)
    -> ( Model.Modelable pageModel, Cmd pageMsg )
    -> ( model, Cmd Msg )
pageUpdateWith toModel toMsg ( subModel, subCmd ) =
    ( toModel subModel, Cmd.map toMsg subCmd )


{-| アプリケーション全体への副作用(Session.Ops)を含んでる場合に使われる更新ヘルパ関数
-}
appUpdateWith :
    (Model.Modelable pageModel -> model)
    -> (pageMsg -> Msg)
    -> Session
    -> ( Model.Modelable pageModel, Cmd pageMsg, Session.Ops )
    -> ( model, Cmd Msg )
appUpdateWith toModel toMsg session ( subModel, subCmd, sessionOps ) =
    let
        ( nextSession, sessionCmd ) =
            ExUpdate.mapCmd GotSessionMsg <|
                Session.runOps sessionOps session

        ( nextModel, pageCmd ) =
            pageUpdateWith toModel toMsg ( Session.update nextSession subModel, subCmd )
    in
    ( nextModel, Cmd.batch [ pageCmd, sessionCmd ] )


updateSession : Model -> Session -> Model
updateSession page newSession =
    case page of
        WaitForLoggingIn flag _ nextRoute ->
            WaitForLoggingIn flag newSession nextRoute

        NotFound flag _ ->
            NotFound flag newSession

        SignIn model ->
            model |> Session.update newSession |> SignIn

        SignUp model ->
            model |> Session.update newSession |> SignUp

        ResetPassword model ->
            model |> Session.update newSession |> ResetPassword

        Bookmarks model ->
            model |> Session.update newSession |> Bookmarks

        NewBookmark model ->
            model |> Session.update newSession |> NewBookmark



-- view


view : Model -> Layout.View Msg
view page =
    case page of
        WaitForLoggingIn _ _ _ ->
            Loading.view

        NotFound _ _ ->
            NotFound.view

        ResetPassword model ->
            model
                |> ResetPassword.view
                |> Layout.mapMsg GotResetPasswordMsg

        SignIn model ->
            model
                |> SignIn.view
                |> Layout.mapMsg GotSignInMsg

        SignUp model ->
            model
                |> SignUp.view
                |> Layout.mapMsg GotSignUpMsg

        Bookmarks model ->
            model
                |> Bookmarks.view
                |> Layout.withHeader (toSession page)
                |> Layout.mapMsg GotBookmarksMsg

        NewBookmark model ->
            model
                |> NewBookmark.view
                |> Layout.withHeader (toSession page)
                |> Layout.mapMsg GotNewBookmarkMsg



-- subscription


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ loggedOut LoggedOut
        , loggedIn (LoggedIn << Decode.decodeValue decode)
        , Sub.map GotBookmarksMsg Bookmarks.subscriptions
        , Sub.map GotSignInMsg SignIn.subscriptions
        , Sub.map GotNewBookmarkMsg NewBookmark.subscriptions
        ]



-- port


type alias InitialData =
    { bookmarks : Bookmarks.Bookmarks
    , currentUser : User.User
    }


port loggedIn : (Decode.Value -> msg) -> Sub msg


port logsOut : () -> Cmd msg


port loggedOut : (() -> msg) -> Sub msg


decode : Decode.Decoder InitialData
decode =
    InitialData
        |> Decode.succeed
        |> Pipeline.required "bookmarks" Bookmarks.decode
        |> Pipeline.required "currentUser" User.decode



-- main


main : Program Decode.Value Model Msg
main =
    Browser.application
        { init = init
        , view = Layout.asDocument GotSessionMsg << view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }
