port module App exposing (init, subscriptions, update)

import App.Model as Model
import App.View as View
import Bookmark.Description as Description
import Bookmark.Title as Title
import Bookmarks
import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Pages.Bookmarks as Bookmarks
import Pages.FB.Bookmark as FBBookmark
import Pages.FB.User as FBUser
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


initPage : Model.Modelable a -> Maybe Route.Routes -> Model
initPage { flag, session } maybeRoute =
    case maybeRoute of
        Nothing ->
            NotFound flag session

        Just Route.Bookmarks ->
            Bookmarks (Bookmarks.init flag session)

        Just (Route.NewBookmark maybeUrl maybeTitle maybeDescription) ->
            NewBookmark.init
                (maybeUrl |> Maybe.withDefault "" |> NewBookmarkUrl.new)
                (maybeTitle |> Maybe.map Title.new |> Maybe.withDefault Title.empty)
                (maybeDescription |> Maybe.map Description.new |> Maybe.withDefault Description.empty)
                flag
                session
                |> NewBookmark

        Just Route.ResetPassword ->
            ResetPassword (ResetPassword.init flag session)

        Just Route.SignIn ->
            SignIn (SignIn.init flag session)

        Just Route.SignUp ->
            SignUp (SignUp.init flag session)


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


view : Model -> View.AppView Msg
view page =
    case page of
        WaitForLoggingIn _ _ _ ->
            Loading.view

        NotFound _ _ ->
            NotFound.view

        ResetPassword model ->
            ResetPassword.view model |> View.mapMsg GotResetPasswordMsg

        SignIn model ->
            SignIn.view model |> View.mapMsg GotSignInMsg

        SignUp model ->
            SignUp.view model |> View.mapMsg GotSignUpMsg

        Bookmarks model ->
            Bookmarks.view model |> View.mapMsg GotBookmarksMsg

        NewBookmark model ->
            NewBookmark.view model |> View.mapMsg GotNewBookmarkMsg



------- Msg ------


type Msg
    = LogsOut
    | LoggedOut ()
    | LoggedIn InitialData
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
                    ( url
                        |> Route.fromUrl
                        |> initPage
                            { flag = model |> toFlag
                            , session = model |> toSession
                            }
                    , Cmd.none
                    )

                ( LoggedOut _, _ ) ->
                    ( model
                        |> toSession
                        |> Session.mapAsNotLoggedIn
                        |> updateSession model
                    , Cmd.none
                    )

                ( LoggedIn { bookmarks, currentUser }, WaitForLoggingIn _ session maybeNextRoute ) ->
                    ( session
                        |> Session.mapAsLoggedIn (bookmarks |> Bookmarks.new) currentUser
                        |> updateSession model
                    , maybeNextRoute
                        |> Maybe.map (Route.replaceUrl (session |> Session.toNavKey))
                        |> Maybe.withDefault (Route.replaceUrl (session |> Session.toNavKey) Route.Bookmarks)
                    )

                ( LoggedIn { bookmarks, currentUser }, SignIn pageModel ) ->
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

                ( GotSignInMsg pageMsg, SignIn pageModel ) ->
                    SignIn.update pageMsg pageModel |> updateWith SignIn GotSignInMsg

                ( GotSignUpMsg pageMsg, SignUp pageModel ) ->
                    SignUp.update pageMsg pageModel |> updateWith SignUp GotSignUpMsg

                ( GotResetPasswordMsg pageMsg, ResetPassword pageModel ) ->
                    ResetPassword.update pageMsg pageModel |> updateWith ResetPassword GotResetPasswordMsg

                ( GotBookmarksMsg pageMsg, Bookmarks pageModel ) ->
                    Bookmarks.update pageMsg pageModel |> updateWith Bookmarks GotBookmarksMsg

                ( GotNewBookmarkMsg pageMsg, NewBookmark pageModel ) ->
                    NewBookmark.update pageMsg pageModel |> updateWith NewBookmark GotNewBookmarkMsg

                ( _, _ ) ->
                    ( model, Cmd.none )
    in
    updated
        |> logInGuard


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
    (Model.Modelable pageModel -> Model)
    -> (pageMsg -> Msg)
    -> ( Model.Modelable pageModel, Cmd pageMsg )
    -> ( Model, Cmd Msg )
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
    let
        pageSubscriptions =
            case page of
                SignIn model ->
                    Sub.map GotSignInMsg (SignIn.subscriptions model)

                NewBookmark model ->
                    Sub.map GotNewBookmarkMsg (NewBookmark.subscriptions model)

                _ ->
                    Sub.none
    in
    Sub.batch
        [ loggedOut LoggedOut
        , loggedIn LoggedIn
        , pageSubscriptions
        ]



------ Port ------


type alias InitialData =
    { bookmarks : List FBBookmark.Bookmark
    , currentUser : FBUser.User
    }


port loggedIn : (InitialData -> msg) -> Sub msg


port loggedOut : (() -> msg) -> Sub msg



------ Main ------


main =
    Browser.application
        { init = init
        , view = \model -> view model |> View.asDocument
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }
