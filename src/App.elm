module App exposing (update, subscriptions, init)

import Models exposing (..)
import Msgs exposing (..)
import Ports exposing (..)
import Views exposing (..)
import Browser
import Browser.Navigation as Nav
import Json.Decode as Decode exposing (field, string)
import String.Interpolate exposing (interpolate)
import Url.Parser as Parser exposing (Parser, (</>), (<?>), oneOf, s)
import Url.Parser.Query as Query
import Url
import Http


init : AppConfig -> Url.Url -> Nav.Key -> (Model, Cmd Msg)
init config url navKey =
  (
    {
      navKey = navKey,
      url = url,
      appConfig = config,
      logInStatus = LoggingIn,
      route = Nothing
    },
    Cmd.none
  )


-- Routing


parser : Parser (Routes -> a) a
parser =
  oneOf [
    Parser.map NewBookmark (s "new_bookmark" <?> Query.string "url" <?> Query.string "title" <?> Query.string "description"),
    Parser.map Bookmarks (s "bookmarks"),
    Parser.map SignIn (s "sign_in"),
    Parser.map SignUp (s "sign_up"),
    Parser.map ResetPassword (s "reset_password")
  ]

fromUrl : Url.Url -> Maybe Routes
fromUrl url =
  { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing } |> Parser.parse parser

pushUrl : Model -> String -> Cmd Msg
pushUrl model path =
  Nav.pushUrl model.navKey ("#/" ++ path)


-- Update


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  let
    fetchUserData = authenticater model
    updateUserData = userDataUpdater model
    updateLoginForm = loginFormUpdater model
    navigateTo = pushUrl model
  in
    case msg of
      UpdatesLoginEmail email ->
        updateLoginForm (\form -> { form | email = email })
      UpdatesLoginPassword password ->
        updateLoginForm (\form -> { form | password = password })

      StartsLoggingIn ->
        case model.logInStatus of
          NotLoggedIn form -> 
            ({ model | logInStatus = LoggingIn }, startLoggingIn form)
          _ -> (model, Cmd.none)
      SucceedsInLoggingIn initialUserData ->
        ({ model | logInStatus = LoggedIn (fromInitialUserData initialUserData) }, navigateTo "bookmarks")
      FailsLoggingIn loginFormWithErr ->
        ({ model | logInStatus = NotLoggedIn loginFormWithErr }, navigateTo "sign_in")
      SignsOut ->
        (model, signsOut ())
      SignedOut _ ->
        ({ model | logInStatus = NotLoggedIn emptyLogin }, navigateTo "sign_in")

      UpdateNewBookmarkUrl url ->
        updateUserData (\userData ->
          let 
            updated = userData.newBookmark |> setUrl url
          in 
            ({ userData | newBookmark = updated }, Cmd.none)
        )
      UpdateNewBookmarkTitle title ->
        updateUserData (\userData ->
          let 
            updated = userData.newBookmark |> setTitle title
          in 
            ({ userData | newBookmark = updated }, Cmd.none)
        )
      UpdateNewBookmarkDescription desc ->
        updateUserData (\userData ->
          let 
            updated = userData.newBookmark |> setDescription desc
          in 
            ({ userData | newBookmark = updated }, Cmd.none)
        )

      CreatesNewbookmark ->
        updateUserData (\userData ->
          ({ userData | newBookmarkCreatingStatus = NewBookmarkCreating }, createsNewBookmark (userData.newBookmark, userData.currentUser))
        )
      CreatingNewBookmarkSucceeded createdBookmark ->
        updateUserData (\userData ->
          ({ userData | newBookmarkCreatingStatus = NewBookmarkCreated (Ok createdBookmark)}, fetchesBookmarks userData.currentUser)
        )
      CreatingNewBookmarkFailed err ->
        (model, Cmd.none) -- TODO: あとでつくる

      FetchingBookmarksSucceeded bookmarks ->
        updateUserData (\userData -> ({ userData | bookmarks = bookmarks }, Cmd.none)) 
      FetchingBookmarksFailed err ->
        (model, Cmd.none) -- TODO: あとでつくる

      StartFetchingWebPageTitle ->
        updateUserData (\userData ->
          ({ userData | urlFetchingStatus = UrlFetching }, fetchUrl model.appConfig.functionUrl userData.newBookmark.url)
        ) 
      NewUrlFetched result ->
        updateUserData (\userData ->
          let
            mappedResult =
              Result.mapError (\err ->
                case err of
                  Http.BadBody errMsg -> UrlFetchingError errMsg
                  _ -> UrlFetchingError "Unexpected error"
              ) result
            (title, description) =
              case mappedResult of
                Ok r -> (r.title, r.description)
                _ -> (userData.newBookmark.title, userData.newBookmark.description)
            updated = userData.newBookmark |> setTitle title |> setDescription description
          in
            ({ userData | newBookmark = updated, urlFetchingStatus = UrlFetched mappedResult }, Cmd.none)
        )

      -- ログインの状況を見てリダイレクトを処理する。ログインしているのにログインページを見せたりする必要はない。
      UrlChanged url ->
        let
          routeM = fromUrl url
          redirectMsg =
            case model.logInStatus of
              NotLoggedIn _ ->
                Maybe.withDefault Cmd.none (Maybe.map (\route ->
                  case route of
                    Bookmarks -> navigateTo "sign_in"
                    _ -> Cmd.none
                ) routeM)
              LoggingIn ->
                navigateTo "sign_in"
              LoggedIn _ ->
                Maybe.withDefault Cmd.none (Maybe.map (\route ->
                  case route of
                    SignIn -> navigateTo "bookmarks" 
                    SignUp -> navigateTo "bookmarks"
                    ResetPassword -> navigateTo "bookmarks"
                    _ -> Cmd.none
                ) routeM)        
          in
            ({ model | url = url, route = fromUrl url }, redirectMsg)

      LinkClicked urlRequest ->
        case urlRequest of
          Browser.External href ->
            (model, Nav.load href)
          Browser.Internal url ->
            case url.fragment of
              Nothing ->
                (model, Cmd.none)
              Just _ ->
                (model, Nav.pushUrl model.navKey (Url.toString url))

authenticater: Model -> (UserData -> (Model, Cmd Msg)) -> (Model, Cmd Msg)
authenticater model cb =
  case model.logInStatus of
    NotLoggedIn _ -> (model, signsOut ())
    LoggingIn -> (model, Cmd.none)
    LoggedIn userData -> cb userData

userDataUpdater : Model -> (UserData -> (UserData, Cmd Msg)) -> (Model, Cmd Msg)
userDataUpdater model updater =
  authenticater model (\userData -> 
    let
      (updatedUserData, msg) = updater userData
    in
      ({ model | logInStatus = LoggedIn updatedUserData }, msg)
  ) 

loginFormUpdater : Model -> (LogInForm -> LogInForm) -> (Model, Cmd Msg)
loginFormUpdater model updater =
  case model.logInStatus of 
    NotLoggedIn form -> ({ model | logInStatus = NotLoggedIn (updater form)}, Cmd.none)
    _ -> (model, Cmd.none)


-- HTTP


fetchUrl : String -> String -> Cmd Msg
fetchUrl functionUrl targetUrl =
  Http.get {
    url = interpolate "{0}?url={1}" [functionUrl, targetUrl],
    expect = Http.expectJson NewUrlFetched urlFetcherDecoder
  }

urlFetcherDecoder : Decode.Decoder UrlFetcherResult
urlFetcherDecoder =
  Decode.map2 UrlFetcherResult
    (field "title" string)
    (field "description" string)


-- Subscription


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [
      logInFailed FailsLoggingIn,
      logInSucceeded SucceedsInLoggingIn,
      signedOut SignedOut,
      creatingNewBookmarkSucceeded CreatingNewBookmarkSucceeded,
      creatingNewBookmarkFailed CreatingNewBookmarkFailed,
      fetchingBookmarksSucceeded FetchingBookmarksSucceeded,
      fetchingBookmarksFailed FetchingBookmarksFailed
    ]


-- Main


main =
    Browser.application {
      init = init,
      view = view,
      update = update,
      subscriptions = subscriptions,
      onUrlChange = UrlChanged,
      onUrlRequest = LinkClicked
    }