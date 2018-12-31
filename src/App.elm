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
      bookmarks = [],
      newBookmark = emptyBookmark (),
      fetchedWebPageTitle = Nothing,
      newLogin = emptyLogin (),
      logInStatus = NotLoggedIn,
      logInError = Nothing,
      currentUser = Nothing
    },
    Cmd.none
  )


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Msgs.UpdatesLoginEmail email ->
      let updated = model.newLogin |> setEmail email
      in ({ model | newLogin = updated }, Cmd.none)
    Msgs.UpdatesLoginPassword password ->
      let updated = model.newLogin |> setPassword password
      in ({ model | newLogin = updated }, Cmd.none)

    Msgs.StartsLoggingIn ->
      ({ model | logInStatus = LoggingIn }, startLoggingIn model.newLogin)
    Msgs.SignsOut ->
      (model, signsOut ())
    Msgs.SignedOut _ ->
      ({ model | currentUser = Nothing }, Cmd.none)
    Msgs.SucceedsInLoggingIn user ->
      ({ model | logInStatus = LogInSucceeded, currentUser = Just user }, Cmd.none)
    Msgs.FailsLoggingIn err ->
      ({ model | logInStatus = LogInFailed, logInError = Just err }, Cmd.none)

    Msgs.UpdateNewBookmarkUrl url ->
      let updated = model.newBookmark |> setUrl url
      in ({ model | newBookmark = updated }, Cmd.none)
    Msgs.UpdateNewBookmarkTitle title ->
      let updated = model.newBookmark |> setTitle title
      in ({ model | newBookmark = updated }, Cmd.none)
    Msgs.UpdateNewBookmarkDescription desc ->
      let updated = model.newBookmark |> setDescription desc
      in ({ model | newBookmark = updated }, Cmd.none)
    Msgs.CreatesNewbookmark->
      (model, createsNewBookmark model.newBookmark)

    Msgs.StartFetchingWebPageTitle ->
      (model, fetchWebPageTitle model.appConfig.functionUrl model.newBookmark.url)
    Msgs.WebPageTitleFetched result ->
      case result of
        Ok titles ->
          ({ model | fetchedWebPageTitle = List.head ( List.map (\x -> x.text) titles ) }, Cmd.none)
        Err err ->
          (model, Cmd.none)

    Msgs.LinkClicked urlRequest ->
      case urlRequest of
        Browser.Internal url ->
          (model, Nav.pushUrl model.navKey (Url.toString url))
        Browser.External href ->
          (model, Nav.load href)
    Msgs.UrlChanged url ->
      ({ model | url = url}, Cmd.none)


-- HTTP

fetchWebPageTitle : String -> String -> Cmd Msg
fetchWebPageTitle functionUrl targetUrl =
  Http.get {
    url = interpolate "{0}?url={1}" [functionUrl, targetUrl],
    expect = Http.expectJson Msgs.WebPageTitleFetched webPageFetchingDecoder
  }

resultDecoder : Decode.Decoder ScrapingResult
resultDecoder =
  Decode.map2 ScrapingResult
    (field "text" string)
    (field "html" string)

webPageFetchingDecoder : Decode.Decoder (List ScrapingResult)
webPageFetchingDecoder =
  Decode.list resultDecoder


-- Subscription


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [
      logInFailed Msgs.FailsLoggingIn,
      logInSucceeded Msgs.SucceedsInLoggingIn,
      signedOut Msgs.SignedOut
    ]


-- Main


main =
    Browser.application {
      init = init,
      view = view,
      update = update,
      subscriptions = subscriptions,
      onUrlChange = Msgs.UrlChanged,
      onUrlRequest = Msgs.LinkClicked
    }