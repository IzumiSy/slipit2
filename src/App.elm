port module App exposing (init, subscriptions, update)

import Browser
import Browser.Navigation as Nav
import Flag exposing (Flag)
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Decode exposing (field, string)
import Pages.Bookmarks as Bookmarks
import Pages.Form.Description as Description
import Pages.Form.Title as Title
import Pages.Form.Url as FormUrl
import Pages.NewBookmark as NewBookmark
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
-- TODO: Redirectステートを導入して認証状態のチェックの間にコンテンツページを見せてしまう事のないようにする


type Model
    = NotFound NotFound.Model
    | SignIn SignIn.Model
    | SignUp SignUp.Model
    | ResetPassword ResetPassword.Model
    | Bookmarks Bookmarks.Model
    | NewBookmark NewBookmark.Model


init : Flag -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flag url navKey =
    ( initPage flag (Session.init url navKey) (Route.fromUrl url)
    , Cmd.none
    )
        |> logInGuard


initPage : Flag -> Session -> Maybe Route.Routes -> Model
initPage flag session maybeRoute =
    case maybeRoute of
        Nothing ->
            NotFound (NotFound.init flag session)

        Just Route.Bookmarks ->
            Bookmarks (Bookmarks.init flag session)

        Just (Route.NewBookmark maybeUrl maybeTitle maybeDescription) ->
            NewBookmark.init
                (maybeUrl |> FormUrl.new)
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
        NotFound model ->
            model.session

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
        NotFound model ->
            model.flag

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


view : Model -> Browser.Document Msg
view page =
    let
        mapMsg toMsg title html =
            { title = "Slip.it | " ++ title
            , body = List.map (Html.map toMsg) [ html ]
            }
    in
    case page of
        NotFound _ ->
            { title = "Slip.it | Not Found", body = [ NotFound.view ] }

        ResetPassword model ->
            model |> ResetPassword.view |> mapMsg GotResetPasswordMsg "Password Reset"

        SignUp model ->
            model |> SignUp.view |> mapMsg GotSignUpMsg "Sign Up"

        SignIn model ->
            model |> SignIn.view |> mapMsg GotSignInMsg "Sign In"

        Bookmarks model ->
            model |> Bookmarks.view |> mapMsg GotBookmarksMsg "Bookmarks"

        NewBookmark model ->
            model |> NewBookmark.view |> mapMsg GotNewBookmarkMsg "New Bookmark"



------- Msg ------


type Msg
    = LogsOut
    | LoggedOut ()
    | LoggedIn Session.UserData
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

                ( LoggedIn { bookmarks, currentUser }, _ ) ->
                    ( model |> toSession |> Session.mapAsLoggedIn bookmarks currentUser |> updateSession model
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

                ( _, _ ) ->
                    ( model, Cmd.none )
    in
    updated
        |> logInGuard


logInGuard : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
logInGuard ( page, cmd ) =
    case page of
        SignIn _ ->
            ( page, cmd )

        SignUp _ ->
            ( page, cmd )

        ResetPassword _ ->
            ( page, cmd )

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
        NotFound _ ->
            page

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
subscriptions page =
    let
        pageSubscriptions =
            case page of
                SignIn model ->
                    Sub.map GotSignInMsg (SignIn.subscriptions model)

                _ ->
                    Sub.none
    in
    Sub.batch
        {-
           [ creatingNewBookmarkSucceeded CreatingNewBookmarkSucceeded
           , creatingNewBookmarkFailed CreatingNewBookmarkFailed
           , fetchingBookmarksSucceeded FetchingBookmarksSucceeded
           , fetchingBookmarksFailed FetchingBookmarksFailed
           ]
        -}
        [ loggedOut LoggedOut
        , loggedIn LoggedIn
        , pageSubscriptions
        ]



------ Port ------
{-
   port createsNewBookmark : ( Bookmark, User ) -> Cmd msg


   port fetchesBookmarks : User -> Cmd msg


   port creatingNewBookmarkSucceeded : (Bookmark -> msg) -> Sub msg


   port creatingNewBookmarkFailed : (BookmarkCreatingError -> msg) -> Sub msg


   port fetchingBookmarksSucceeded : (List Bookmark -> msg) -> Sub msg


   port fetchingBookmarksFailed : (BookmarksFetchingError -> msg) -> Sub msg
-}


port loggedOut : (() -> msg) -> Sub msg


port loggedIn : (Session.UserData -> msg) -> Sub msg



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
