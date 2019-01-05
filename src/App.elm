module App exposing (update, subscriptions, init)

import Models exposing (..)
import Msgs exposing (..)
import Ports exposing (..)
import Views exposing (..)
import Browser
import Browser.Navigation as Nav
import Json.Decode as Decode exposing (field, string)
import String.Interpolate exposing (interpolate)
import Url
import Http


init : AppConfig -> Url.Url -> Nav.Key -> (Model, Cmd Msg)
init config url navKey =
  (
    {
      navKey = navKey,
      url = url,
      appConfig = config,
      logInStatus = LoggingIn
    },
    Cmd.none
  )


-- Update


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  let
    fetchUserData = authenticater model
    updateUserData = userDataUpdater model
    updateLoginForm = loginFormUpdater model
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
        ({ model | logInStatus = LoggedIn (fromInitialUserData initialUserData) }, Cmd.none)
      FailsLoggingIn loginFormWithErr ->
        ({ model | logInStatus = NotLoggedIn loginFormWithErr }, Cmd.none)
      SignsOut ->
        (model, signsOut ())
      SignedOut _ ->
        ({ model | logInStatus = NotLoggedIn emptyLogin }, Cmd.none)

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
          ({ userData | titleFetchingStatus = TitleFetching }, fetchWebPageTitle model.appConfig.functionUrl userData.newBookmark.url)
        ) 
      WebPageTitleFetched result ->
        updateUserData (\userData ->
          let
            mappedResult =
              Result.mapError (\err ->
                case err of
                  Http.BadBody errMsg -> TitleFetchingError errMsg
                  _ -> TitleFetchingError "Unexpected error"
              ) result
            title =
              case mappedResult of
                Ok text -> text
                _ -> userData.newBookmark.title
            updated = userData.newBookmark |> setTitle title
          in
            ({ userData | newBookmark = updated, titleFetchingStatus = TitleFetched mappedResult }, Cmd.none)
        )

      LinkClicked urlRequest ->
        case urlRequest of
          Browser.Internal url ->
            (model, Nav.pushUrl model.navKey (Url.toString url))
          Browser.External href ->
            (model, Nav.load href)
      UrlChanged url ->
        ({ model | url = url}, Cmd.none)

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


fetchWebPageTitle : String -> String -> Cmd Msg
fetchWebPageTitle functionUrl targetUrl =
  Http.get {
    url = interpolate "{0}?url={1}" [functionUrl, targetUrl],
    expect = Http.expectString WebPageTitleFetched
  }


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