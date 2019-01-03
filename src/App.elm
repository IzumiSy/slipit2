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
      newLogin = emptyLogin (),
      newBookmark = emptyBookmark (),
      logInStatus = NotLoggedIn,
      titleFetchingStatus = TitleNotFetched
    },
    Cmd.none
  )


-- Update


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  let 
    authenticateAsUser = authenticate model
  in 
    case msg of
      UpdatesLoginEmail email ->
        let updated = model.newLogin |> setEmail email
        in ({ model | newLogin = updated }, Cmd.none)
      UpdatesLoginPassword password ->
        let updated = model.newLogin |> setPassword password
        in ({ model | newLogin = updated }, Cmd.none)

      StartsLoggingIn ->
        ({ model | logInStatus = LoggingIn }, startLoggingIn model.newLogin)
      SucceedsInLoggingIn userData ->
        ({ model | logInStatus = LoggedIn (Result.Ok userData) }, Cmd.none)
      FailsLoggingIn err ->
        ({ model | logInStatus = LoggedIn (Result.Err err) }, Cmd.none)
      SignsOut ->
        (model, signsOut ())
      SignedOut _ ->
        ({ model | logInStatus = NotLoggedIn }, Cmd.none)

      UpdateNewBookmarkUrl url ->
        let updated = model.newBookmark |> setUrl url
        in ({ model | newBookmark = updated }, Cmd.none)
      UpdateNewBookmarkTitle title ->
        let updated = model.newBookmark |> setTitle title
        in ({ model | newBookmark = updated }, Cmd.none)
      UpdateNewBookmarkDescription desc ->
        let updated = model.newBookmark |> setDescription desc
        in ({ model | newBookmark = updated }, Cmd.none)
      CreatesNewbookmark->
        authenticateAsUser (\userData ->
          (model, createsNewBookmark (model.newBookmark, userData.currentUser))
        )

      StartFetchingWebPageTitle ->
        (model, fetchWebPageTitle model.appConfig.functionUrl model.newBookmark.url)
      WebPageTitleFetched result ->
        let 
          r = 
            Result.mapError (\err ->
              case err of
                Http.BadBody errMsg -> TitleFetchingError errMsg
                _ -> TitleFetchingError "Unexpected error"
            ) result
        in 
          ({ model | titleFetchingStatus = TitleFetched r }, Cmd.none)

      LinkClicked urlRequest ->
        case urlRequest of
          Browser.Internal url ->
            (model, Nav.pushUrl model.navKey (Url.toString url))
          Browser.External href ->
            (model, Nav.load href)
      UrlChanged url ->
        ({ model | url = url}, Cmd.none)

authenticate : Model -> (UserData -> (Model, Cmd Msg)) -> (Model, Cmd Msg)
authenticate model cb =
  case model.logInStatus of
    NotLoggedIn -> (model, signsOut ()) 
    LoggingIn -> (model, Cmd.none) 
    LoggedIn result ->
      case result of
        Ok userData -> cb userData
        Err err -> ({ model | logInStatus = LoggedIn (Result.Err err) }, Cmd.none)


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
      signedOut SignedOut
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