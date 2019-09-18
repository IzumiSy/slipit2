port module App exposing (init, subscriptions, update)

import App.Header as AppHeader
import App.Model as Model
import Bookmark exposing (Bookmark)
import Bookmark.Description as Description
import Bookmark.Title as Title
import Bookmarks
import Bookmarks.FB.Bookmark as FBBookmark
import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Pages
import Pages.Bookmarks as Bookmarks
import Pages.FB.User as FBUser
import Pages.Layout as Layout
import Pages.Loading as Loading
import Pages.NewBookmark as NewBookmark
import Pages.NewBookmark.Url as NewBookmarkUrl exposing (Url)
import Pages.NotFound as NotFound
import Pages.ResetPassword as ResetPassword
import Pages.SignIn as SignIn
import Pages.SignUp as SignUp
import Route
import Session exposing (Session)
import Url
import Url.Parser as Parser exposing ((</>), (<?>), Parser, oneOf, s)
import Url.Parser.Query as Query



------ Model ------


type Model
    = WaitForLoggingIn Model.Flag Session (Maybe Route.Routes)
    | NotFound Model.Flag Session
    | SignIn SignIn.Model
    | SignUp SignUp.Model
    | ResetPassword ResetPassword.Model
    | Bookmarks Bookmarks.Model
    | NewBookmark NewBookmark.Model



------ Init ------


init : Model.Flag -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flag url navKey =
    ( WaitForLoggingIn flag (Session.init url navKey) (Route.fromUrl url)
    , Cmd.none
    )


initPage : Model.Modelable a -> Maybe Route.Routes -> ( Model, Cmd Msg )
initPage { flag, session } maybeRoute =
    case maybeRoute of
        Nothing ->
            ( NotFound flag session, Cmd.none )

        Just Route.Bookmarks ->
            Bookmarks.init flag session
                |> Tuple.mapFirst Bookmarks
                |> Tuple.mapSecond (Cmd.map GotBookmarksMsg)

        Just (Route.NewBookmark maybeUrl maybeTitle maybeDescription) ->
            NewBookmark.init
                (maybeUrl |> Maybe.withDefault "" |> NewBookmarkUrl.new)
                (maybeTitle |> Maybe.map Title.new |> Maybe.withDefault Title.empty)
                (maybeDescription |> Maybe.map Description.new |> Maybe.withDefault Description.empty)
                flag
                session
                |> Tuple.mapFirst NewBookmark
                |> Tuple.mapSecond (Cmd.map GotNewBookmarkMsg)

        Just Route.ResetPassword ->
            ResetPassword.init flag session
                |> Tuple.mapFirst ResetPassword
                |> Tuple.mapSecond (Cmd.map GotResetPasswordMsg)

        Just Route.SignIn ->
            SignIn.init flag session
                |> Tuple.mapFirst SignIn
                |> Tuple.mapSecond (Cmd.map GotSignInMsg)

        Just Route.SignUp ->
            SignUp.init flag session
                |> Tuple.mapFirst SignUp
                |> Tuple.mapSecond (Cmd.map GotSignUpMsg)


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


toFlag : Model -> Model.Flag
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



------ View ------


view : Model -> Layout.View Msg
view page =
    case page of
        WaitForLoggingIn _ _ _ ->
            Loading.view

        NotFound _ _ ->
            NotFound.view

        ResetPassword model ->
            ResetPassword.view model
                |> Layout.mapMsg GotResetPasswordMsg

        SignIn model ->
            SignIn.view model
                |> Layout.mapMsg GotSignInMsg

        SignUp model ->
            SignUp.view model
                |> Layout.mapMsg GotSignUpMsg

        Bookmarks model ->
            Bookmarks.view model
                |> Layout.withHeader (toSession page) Bookmarks.GotAppHeaderMsg
                |> Layout.mapMsg GotBookmarksMsg

        NewBookmark model ->
            NewBookmark.view model
                |> Layout.withHeader (toSession page) NewBookmark.GotAppHeaderMsg
                |> Layout.mapMsg GotNewBookmarkMsg



------- Msg ------


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



------ Update ------


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        updated =
            case ( msg, model ) of
                ( LinkClicked urlRequest, _ ) ->
                    case urlRequest of
                        Browser.External href ->
                            ( model, Nav.load href )

                        Browser.Internal url ->
                            ( model
                            , Nav.pushUrl
                                (model |> toSession |> Session.toNavKey)
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
                                |> Session.mapAsLoggedIn (bookmarks |> Bookmarks.new) currentUser
                                |> updateSession model
                            , maybeNextRoute
                                |> Maybe.map (Route.replaceUrl (session |> Session.toNavKey))
                                |> Maybe.withDefault (Route.replaceUrl (session |> Session.toNavKey) Route.Bookmarks)
                            )

                        Err _ ->
                            ( model, Cmd.none )

                ( LoggedIn result, SignIn pageModel ) ->
                    case result of
                        Ok { bookmarks, currentUser } ->
                            ( model
                                |> toSession
                                |> Session.mapAsLoggedIn (bookmarks |> Bookmarks.new) currentUser
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
                        |> updateWith SignIn GotSignInMsg

                ( GotSignUpMsg pageMsg, SignUp pageModel ) ->
                    pageModel
                        |> SignUp.update pageMsg
                        |> updateWith SignUp GotSignUpMsg

                ( GotResetPasswordMsg pageMsg, ResetPassword pageModel ) ->
                    pageModel
                        |> ResetPassword.update pageMsg
                        |> updateWith ResetPassword GotResetPasswordMsg

                ( GotBookmarksMsg pageMsg, Bookmarks pageModel ) ->
                    pageModel
                        |> Bookmarks.update pageMsg
                        |> updateWith Bookmarks GotBookmarksMsg

                ( GotNewBookmarkMsg pageMsg, NewBookmark pageModel ) ->
                    pageModel
                        |> NewBookmark.update pageMsg
                        |> updateWith NewBookmark GotNewBookmarkMsg

                ( _, _ ) ->
                    ( model, Cmd.none )
    in
    logInGuard updated


logInGuard : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
logInGuard ( page, cmd ) =
    let
        toBookmarksIfNotLoggedIn =
            if page |> toSession |> Session.isLoggedIn then
                ( page, Route.replaceUrl (page |> toSession |> Session.toNavKey) Route.Bookmarks )

            else
                ( page, cmd )
    in
    case page of
        SignIn _ ->
            toBookmarksIfNotLoggedIn

        SignUp _ ->
            toBookmarksIfNotLoggedIn

        ResetPassword _ ->
            toBookmarksIfNotLoggedIn

        _ ->
            if page |> toSession |> Session.isLoggedIn then
                ( page, cmd )

            else
                ( page, Route.replaceUrl (page |> toSession |> Session.toNavKey) Route.SignIn )


updateWith :
    (Model.Modelable pageModel -> model)
    -> (pageMsg -> msg)
    -> ( Model.Modelable pageModel, Cmd pageMsg )
    -> ( model, Cmd msg )
updateWith toModel toMsg ( subModel, subCmd ) =
    ( toModel subModel, Cmd.map toMsg subCmd )


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



------ Subscription ------


subscriptions : Model -> Sub Msg
subscriptions page =
    Sub.batch <|
        [ loggedOut LoggedOut
        , loggedIn (LoggedIn << Decode.decodeValue decodeInitialData)
        ]
            ++ List.singleton
                (case page of
                    SignIn model ->
                        Sub.map GotSignInMsg SignIn.subscriptions

                    NewBookmark model ->
                        Sub.map GotNewBookmarkMsg NewBookmark.subscriptions

                    Bookmarks _ ->
                        Sub.map GotBookmarksMsg Bookmarks.subscriptions

                    _ ->
                        Sub.none
                )



------ Port ------


type alias InitialData =
    { bookmarks : List Bookmark
    , currentUser : FBUser.User
    }


port loggedIn : (Decode.Value -> msg) -> Sub msg


port logsOut : () -> Cmd msg


port loggedOut : (() -> msg) -> Sub msg


decodeInitialData : Decode.Decoder InitialData
decodeInitialData =
    Decode.succeed InitialData
        |> Pipeline.required "bookmarks" (Decode.list Bookmark.decoder)
        |> Pipeline.required "currentUser" decodeCurrentUser


decodeCurrentUser : Decode.Decoder FBUser.User
decodeCurrentUser =
    Decode.succeed FBUser.User
        |> Pipeline.required "uid" Decode.string
        |> Pipeline.required "email" Decode.string
        |> Pipeline.optional "displayName" (Decode.map Just Decode.string) Nothing



------ Main ------


main =
    Browser.application
        { init = init
        , view = \model -> view model |> Layout.asDocument
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }
