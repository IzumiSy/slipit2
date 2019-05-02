port module App exposing (init, subscriptions, update)

import Browser
import Browser.Navigation as Nav
import Flag exposing (Flag)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as Decode exposing (field, string)
import Models exposing (..)
import Pages.NotFound as NotFound
import Pages.ResetPassword as ResetPassword
import Pages.SignIn as SignIn
import Pages.SignUp as SignUp
import Route
import Session exposing (Session)
import String.Interpolate exposing (interpolate)
import Url
import Url.Parser as Parser exposing ((</>), (<?>), Parser, oneOf, s)
import Url.Parser.Query as Query



------ Init ------


type Model
    = NotFound NotFound.Model
    | SignIn SignIn.Model
    | SignUp SignUp.Model
    | ResetPassword ResetPassword.Model


init : Flag -> Url.Url -> Nav.Key -> ( Model, Cmd msg )
init flag url navKey =
    let
        session =
            Session.init url navKey
    in
    ( initPage (SignIn (SignIn.init flag session)) (Route.fromUrl url)
    , Cmd.none
    )


toSession : Model -> Session
toSession page =
    case page of
        NotFound model ->
            model.session

        SignIn model ->
            model.session

        SignUp model ->
            model.session

        ResetPassword model ->
            model.session


toFlag : Model -> Flag
toFlag page =
    case page of
        NotFound model ->
            model.flag

        SignIn model ->
            model.flag

        SignUp model ->
            model.flag

        ResetPassword model ->
            model.flag



------ View ------


view : Model -> Browser.Document Msg
view page =
    let
        mapMsg toMsg title html =
            { title = "Slip.it | " ++ title
            , body = List.map (Html.map toMsg) [ html ]
            }
    in
    case page of
        NotFound model ->
            { title = "Slip.it | Not Found", body = [ NotFound.view ] }

        ResetPassword model ->
            model |> ResetPassword.view |> mapMsg GotResetPasswordMsg "Password Reset"

        SignUp model ->
            model |> SignUp.view |> mapMsg GotSignUpMsg "Sign Up"

        SignIn model ->
            model |> SignIn.view |> mapMsg GotSignInMsg "Sign In"



------- Msg ------


type
    Msg
    {-
       | UpdateNewBookmarkUrl String
       | UpdateNewBookmarkTitle String
       | UpdateNewBookmarkDescription String
       | CreatesNewbookmark
       | CreatingNewBookmarkSucceeded Bookmark
       | CreatingNewBookmarkFailed BookmarkCreatingError
       | FetchingBookmarksSucceeded (List Bookmark)
       | FetchingBookmarksFailed BookmarksFetchingError
       | StartFetchingWebPageTitle
       | NewUrlFetched (Result Http.Error UrlFetcherResult)
    -}
    = Noop
    | SignsOut
    | SignedOut ()
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotSignInMsg SignIn.Msg
    | GotSignUpMsg SignUp.Msg
    | GotResetPasswordMsg ResetPassword.Msg



------ Update ------


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.External href ->
                    ( model, Nav.load href )

                Browser.Internal url ->
                    ( model, Nav.pushUrl (model |> toSession |> Session.toNavKey) (Url.toString url) )

        ( UrlChanged url, _ ) ->
            ( url |> Route.fromUrl |> initPage model, Cmd.none )

        ( SignedOut _, _ ) ->
            ( model |> toSession |> Session.mapAsNotLoggedIn |> updateSession model, Cmd.none )

        ( GotSignInMsg pageMsg, SignIn pageModel ) ->
            SignIn.update pageMsg pageModel |> updateWith SignIn GotSignInMsg

        ( GotSignUpMsg pageMsg, SignUp pageModel ) ->
            SignUp.update pageMsg pageModel |> updateWith SignUp GotSignUpMsg

        ( GotResetPasswordMsg pageMsg, ResetPassword pageModel ) ->
            ResetPassword.update pageMsg pageModel |> updateWith ResetPassword GotResetPasswordMsg

        ( _, _ ) ->
            ( model, Cmd.none )


updateWith : (pageModel -> Model) -> (pageMsg -> Msg) -> ( pageModel, Cmd pageMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg ( subModel, subCmd ) =
    ( toModel subModel, Cmd.map toMsg subCmd )


initPage : Model -> Maybe Route.Routes -> Model
initPage currentModel maybeRoute =
    let
        flag =
            currentModel |> toFlag

        session =
            currentModel |> toSession
    in
    case maybeRoute of
        Nothing ->
            NotFound (NotFound.init flag session)

        Just Route.Bookmarks ->
            currentModel

        Just (Route.NewBookmark _ _ _) ->
            currentModel

        Just Route.ResetPassword ->
            ResetPassword (ResetPassword.init flag session)

        Just Route.SignIn ->
            SignIn (SignIn.init flag session)

        Just Route.SignUp ->
            SignUp (SignUp.init flag session)


updateSession : Model -> Session -> Model
updateSession page newSession =
    case page of
        NotFound _ ->
            page

        SignIn model ->
            model |> Session.update newSession |> SignIn

        SignUp model ->
            model |> Session.update newSession |> SignUp

        ResetPassword model ->
            model |> Session.update newSession |> ResetPassword



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
           SucceedsInLoggingIn initialUserData ->
               ( { model | logInStatus = LoggedIn (fromInitialUserData initialUserData) }, navigateTo "bookmarks" )

           FailsLoggingIn loginFormWithErr ->
               ( { model | logInStatus = NotLoggedIn loginFormWithErr }, navigateTo "sign_in" )

           SignsOut ->
               ( model, signsOut () )

           SignedOut _ ->
               ( { model | logInStatus = NotLoggedIn emptyLogin }, navigateTo "sign_in" )

           UpdateNewBookmarkUrl url ->
               updateUserData
                   (\userData ->
                       let
                           updated =
                               userData.newBookmark |> setUrl url
                       in
                       ( { userData | newBookmark = updated }, Cmd.none )
                   )

           UpdateNewBookmarkTitle title ->
               updateUserData
                   (\userData ->
                       let
                           updated =
                               userData.newBookmark |> setTitle title
                       in
                       ( { userData | newBookmark = updated }, Cmd.none )
                   )

           UpdateNewBookmarkDescription desc ->
               updateUserData
                   (\userData ->
                       let
                           updated =
                               userData.newBookmark |> setDescription desc
                       in
                       ( { userData | newBookmark = updated }, Cmd.none )
                   )

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
           FetchingBookmarksSucceeded bookmarks ->
               updateUserData (\userData -> ( { userData | bookmarks = bookmarks }, Cmd.none ))

           FetchingBookmarksFailed err ->
               ( model, Cmd.none )

           -- TODO: あとでつくる
           StartFetchingWebPageTitle ->
               updateUserData
                   (\userData ->
                       ( { userData | urlFetchingStatus = UrlFetching }, fetchUrl model.appConfig.functionUrl userData.newBookmark.url )
                   )

           NewUrlFetched result ->
               updateUserData
                   (\userData ->
                       let
                           mappedResult =
                               Result.mapError
                                   (\err ->
                                       case err of
                                           Http.BadBody errMsg ->
                                               UrlFetchingError errMsg

                                           _ ->
                                               UrlFetchingError "Unexpected error"
                                   )
                                   result

                           ( title, description ) =
                               case mappedResult of
                                   Ok r ->
                                       ( r.title, r.description )

                                   _ ->
                                       ( userData.newBookmark.title, userData.newBookmark.description )

                           updated =
                               userData.newBookmark |> setTitle title |> setDescription description
                       in
                       ( { userData | newBookmark = updated, urlFetchingStatus = UrlFetched mappedResult }, Cmd.none )
                   )

           -- ログインの状況を見てリダイレクトを処理する。ログインしているのにログインページを見せたりする必要はない。
           UrlChanged url ->
               let
                   routeM =
                       Route.fromUrl url

                   redirectMsg =
                       case model.logInStatus of
                           NotLoggedIn _ ->
                               Maybe.withDefault Cmd.none
                                   (routeM
                                       |> Maybe.map
                                           (\route ->
                                               case route of
                                                   Route.Bookmarks ->
                                                       navigateTo "sign_in"

                                                   _ ->
                                                       Cmd.none
                                           )
                                   )

                           LoggingIn ->
                               navigateTo "sign_in"

                           LoggedIn _ ->
                               Maybe.withDefault Cmd.none
                                   (Maybe.map
                                       (\route ->
                                           case route of
                                               Route.SignIn ->
                                                   navigateTo "bookmarks"

                                               Route.SignUp ->
                                                   navigateTo "bookmarks"

                                               Route.ResetPassword ->
                                                   navigateTo "bookmarks"

                                               _ ->
                                                   Cmd.none
                                       )
                                       routeM
                                   )
               in
               ( { model | url = url, route = Route.fromUrl url }, redirectMsg )



   authenticater : Model -> (UserData -> ( Model, Cmd Msg )) -> ( Model, Cmd Msg )
   authenticater model cb =
       case model.logInStatus of
           NotLoggedIn _ ->
               ( model, signsOut () )

           LoggingIn ->
               ( model, Cmd.none )

           LoggedIn userData ->
               cb userData


   userDataUpdater : Model -> (UserData -> ( UserData, Cmd Msg )) -> ( Model, Cmd Msg )
   userDataUpdater model updater =
       authenticater model
           (\userData ->
               let
                   ( updatedUserData, msg ) =
                       updater userData
               in
               ( { model | logInStatus = LoggedIn updatedUserData }, msg )
           )


   loginFormUpdater : Model -> (LogInForm -> LogInForm) -> ( Model, Cmd Msg )
   loginFormUpdater model updater =
       case model.logInStatus of
           NotLoggedIn form ->
               ( { model | logInStatus = NotLoggedIn (updater form) }, Cmd.none )

           _ ->
               ( model, Cmd.none )
-}
-- HTTP
{-
   fetchUrl : String -> String -> Cmd Msg
   fetchUrl functionUrl targetUrl =
       Http.get
           { url = interpolate "{0}?url={1}" [ functionUrl, targetUrl ]
           , expect = Http.expectJson NewUrlFetched urlFetcherDecoder
           }


   urlFetcherDecoder : Decode.Decoder UrlFetcherResult
   urlFetcherDecoder =
       Decode.map2 UrlFetcherResult
           (field "title" string)
           (field "description" string)
-}
------ Subscription ------


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        {-
           [ logInFailed FailsLoggingIn
           , logInSucceeded SucceedsInLoggingIn
           , creatingNewBookmarkSucceeded CreatingNewBookmarkSucceeded
           , creatingNewBookmarkFailed CreatingNewBookmarkFailed
           , fetchingBookmarksSucceeded FetchingBookmarksSucceeded
           , fetchingBookmarksFailed FetchingBookmarksFailed
           ]
        -}
        [ signedOut SignedOut ]



------ Port ------
{-
   port createsNewBookmark : ( Bookmark, User ) -> Cmd msg


   port fetchesBookmarks : User -> Cmd msg


   port creatingNewBookmarkSucceeded : (Bookmark -> msg) -> Sub msg


   port creatingNewBookmarkFailed : (BookmarkCreatingError -> msg) -> Sub msg


   port fetchingBookmarksSucceeded : (List Bookmark -> msg) -> Sub msg


   port fetchingBookmarksFailed : (BookmarksFetchingError -> msg) -> Sub msg


   port logInSucceeded : (InitialUserData -> msg) -> Sub msg


   port logInFailed : (LoginPayload -> msg) -> Sub msg
-}


port signsOut : () -> Cmd msg


port signedOut : (() -> msg) -> Sub msg



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
