port module App exposing (init, subscriptions, update)

import Bookmark.Description as Description
import Bookmark.Title as Title
import Bookmarks
import Browser
import Browser.Navigation as Nav
import Flag exposing (Flag)
import Html exposing (..)
import Html.Attributes exposing (..)
import Pages.Bookmarks as Bookmarks
import Pages.FB.Bookmark as FBBookmark
import Pages.FB.User as FBUser
import Pages.NewBookmark as NewBookmark
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
    = WaitForLoggingIn Flag Session (Maybe Route.Routes)
    | NotFound Flag Session
    | SignIn SignIn.Model
    | SignUp SignUp.Model
    | ResetPassword ResetPassword.Model
    | Bookmarks Bookmarks.Model
    | NewBookmark NewBookmark.Model



------ Init ------


init : Flag -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flag url navKey =
    ( WaitForLoggingIn flag (Session.init url navKey) (Route.fromUrl url)
    , Cmd.none
    )


initPage : Flag -> Session -> Maybe Route.Routes -> Model
initPage flag session maybeRoute =
    case maybeRoute of
        Nothing ->
            NotFound flag session

        Just Route.Bookmarks ->
            Bookmarks (Bookmarks.init flag session)

        Just (Route.NewBookmark maybeUrl maybeTitle maybeDescription) ->
            NewBookmark.init
                (maybeUrl |> Maybe.withDefault "" |> Url.fromString)
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


toFlag : Model -> Flag
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


toView : Html.Html msg -> Browser.Document msg
toView html =
    { title = "Slip.it"
    , body = [ html ]
    }


view : Model -> Browser.Document Msg
view page =
    let
        mapMsg toMsg { title, body } =
            { title = title
            , body = List.map (Html.map toMsg) body
            }

        mapTitle pageTitle { title, body } =
            { title = title ++ " | " ++ pageTitle
            , body = body
            }
    in
    case page of
        WaitForLoggingIn _ _ _ ->
            div [] [ text "Loading..." ]
                |> toView
                |> mapTitle "Loading"

        NotFound _ _ ->
            div [] [ text "Not Found" ]
                |> toView
                |> mapTitle "Not Found"

        ResetPassword model ->
            model
                |> ResetPassword.view
                |> toView
                |> mapMsg GotResetPasswordMsg
                |> mapTitle "Password Reset"

        SignUp model ->
            model
                |> SignUp.view
                |> toView
                |> mapMsg GotSignUpMsg
                |> mapTitle "Sign Up"

        SignIn model ->
            model
                |> SignIn.view
                |> toView
                |> mapMsg GotSignInMsg
                |> mapTitle "Sign In"

        Bookmarks model ->
            model
                |> Bookmarks.view
                |> toView
                |> mapMsg GotBookmarksMsg
                |> mapTitle "Bookmarks"

        NewBookmark model ->
            model
                |> NewBookmark.view
                |> toView
                |> mapMsg GotNewBookmarkMsg
                |> mapTitle "New Bookmark"



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
                            ( model, Nav.pushUrl (model |> toSession |> Session.toNavKey) (Url.toString url) )

                ( UrlChanged url, _ ) ->
                    ( url |> Route.fromUrl |> initPage (model |> toFlag) (model |> toSession), Cmd.none )

                ( LoggedOut _, _ ) ->
                    ( model |> toSession |> Session.mapAsNotLoggedIn |> updateSession model, Cmd.none )

                ( LoggedIn { bookmarks, currentUser }, WaitForLoggingIn _ session maybeNextRoute ) ->
                    ( session |> Session.mapAsLoggedIn (bookmarks |> Bookmarks.new) currentUser |> updateSession model
                    , maybeNextRoute
                        |> Maybe.map (Route.replaceUrl (session |> Session.toNavKey))
                        |> Maybe.withDefault (Route.replaceUrl (session |> Session.toNavKey) Route.Bookmarks)
                    )

                ( LoggedIn { bookmarks, currentUser }, SignIn pageModel ) ->
                    ( model |> toSession |> Session.mapAsLoggedIn (bookmarks |> Bookmarks.new) currentUser |> updateSession model
                    , Route.replaceUrl (model |> toSession |> Session.toNavKey) Route.Bookmarks
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


updateWith : (pageModel -> Model) -> (pageMsg -> Msg) -> ( pageModel, Cmd pageMsg ) -> ( Model, Cmd Msg )
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



{-
   update : Msg -> Model -> ( Model, Cmd Msg )
   update msg model =
       let
           fetchUserData =
               authenticater model

           updateUserData =
               userDataUpdater model

           updateLoginForm =
               loginFormUpdater model

           navigateTo =
               Route.pushUrl model.navKey
       in
       case msg of
           CreatesNewbookmark ->
               updateUserData
                   (\userData ->
                       ( { userData | newBookmarkCreatingStatus = NewBookmarkCreating }, createsNewBookmark ( userData.newBookmark, userData.currentUser ) )
                   )

           CreatingNewBookmarkSucceeded createdBookmark ->
               updateUserData
                   (\userData ->
                       ( { userData | newBookmarkCreatingStatus = NewBookmarkCreated (Ok createdBookmark) }, fetchesBookmarks userData.currentUser )
                   )

           CreatingNewBookmarkFailed err ->
               ( model, Cmd.none )

           -- TODO: あとでつくる
           StartFetchingWebPageTitle ->
               updateUserData
                   (\userData ->
                       ( { userData | urlFetchingStatus = UrlFetching }, fetchUrl model.appConfig.functionUrl userData.newBookmark.url )
                   )
-}
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
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }
