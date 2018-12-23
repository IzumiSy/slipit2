module App exposing (Msg, update, view, subscriptions, init)

import Models exposing (..)
import Ports exposing (..)
import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Decode exposing (field, string)
import String.Interpolate exposing (interpolate)
import Url
import Http


-- Model


type alias AppConfig =
  {
    functionUrl: String
  }

type alias Model =
  {
    navKey: Nav.Key,
    url: Url.Url,
    appConfig: AppConfig,
    bookmarks: List Bookmark,
    newBookmark: Bookmark,
    fetchedWebPageTitle: Maybe String,
    newLogin: LoginForm,
    logInStatus: LoginStatus,
    logInError: Maybe LoginError,
    currentUser: Maybe User
  }

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


-- Msg


type Msg =
  UpdatesLoginEmail String
  | UpdatesLoginPassword String
  | StartsLoggingIn
  | SucceedsInLoggingIn User
  | FailsLoggingIn LoginError
  | SignsOut
  | SignedOut ()
  | UpdateNewBookmarkUrl String
  | UpdateNewBookmarkTitle String
  | UpdateNewBookmarkDescription String
  | StartFetchingWebPageTitle
  | WebPageTitleFetched (Result Http.Error (List ScrapingResult))
  | LinkClicked Browser.UrlRequest
  | UrlChanged Url.Url


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    UpdatesLoginEmail email ->
      let updated = model.newLogin |> setEmail email
      in ({ model | newLogin = updated }, Cmd.none)
    UpdatesLoginPassword password ->
      let updated = model.newLogin |> setPassword password
      in ({ model | newLogin = updated }, Cmd.none)

    StartsLoggingIn ->
      ({ model | logInStatus = LoggingIn }, startLoggingIn model.newLogin)
    SignsOut ->
      (model, signsOut ())
    SignedOut _ ->
      ({ model | currentUser = Nothing }, Cmd.none)
    SucceedsInLoggingIn user ->
      ({ model | logInStatus = LogInSucceeded, currentUser = Just user }, Cmd.none)
    FailsLoggingIn err ->
      ({ model | logInStatus = LogInFailed, logInError = Just err }, Cmd.none)

    UpdateNewBookmarkUrl url ->
      let updated = model.newBookmark |> setUrl url
      in ({ model | newBookmark = updated }, Cmd.none)
    UpdateNewBookmarkTitle title ->
      let updated = model.newBookmark |> setTitle title
      in ({ model | newBookmark = updated }, Cmd.none)
    UpdateNewBookmarkDescription desc ->
      let updated = model.newBookmark |> setDescription desc
      in ({ model | newBookmark = updated }, Cmd.none)

    StartFetchingWebPageTitle ->
      (model, fetchWebPageTitle model.appConfig.functionUrl model.newBookmark.url)
    WebPageTitleFetched result ->
      case result of
        Ok titles ->
          ({ model | fetchedWebPageTitle = List.head ( List.map (\x -> x.text) titles ) }, Cmd.none)
        Err err ->
          (model, Cmd.none)

    LinkClicked urlRequest ->
      case urlRequest of
        Browser.Internal url ->
          (model, Nav.pushUrl model.navKey (Url.toString url))
        Browser.External href ->
          (model, Nav.load href)
    UrlChanged url ->
      ({ model | url = url}, Cmd.none)


-- HTTP

fetchWebPageTitle : String -> String -> Cmd Msg
fetchWebPageTitle functionUrl targetUrl =
  Http.get {
    url = interpolate "{0}?url={1}" [functionUrl, targetUrl],
    expect = Http.expectJson WebPageTitleFetched webPageFetchingDecoder
  }

type alias ScrapingResult =
  {
    text: String,
    html: String
  }

resultDecoder : Decode.Decoder ScrapingResult
resultDecoder =
  Decode.map2 ScrapingResult
    (field "text" string)
    (field "html" string)

webPageFetchingDecoder : Decode.Decoder (List ScrapingResult)
webPageFetchingDecoder =
  Decode.list resultDecoder


-- View
-- TODO: ログインエラーを表示する


view : Model -> Browser.Document Msg
view model =
  {
    title = "This is title",
    body =
      case model.currentUser of
        Just user ->
          [homeView user model.fetchedWebPageTitle]
        Nothing ->
          [loginView model]
  }

homeView : User -> Maybe String -> Html Msg
homeView user fetchedWebPageTitle =
  let
    fetchedTitle = case fetchedWebPageTitle of
      Just title -> title
      Nothing -> "n/a"
  in
    div [] [
      div [] [text (String.append "Current user: " user.email)],
      div [] [button [onClick SignsOut] [text "sign out"]],

      p [] [text "Fetch webpage title"],
      div [] [
        Html.form[onSubmitWithPrevented StartFetchingWebPageTitle] [
          div [] [
            label [] [
              text "url:",
              input [placeholder "Url to bookmark", onInput UpdateNewBookmarkUrl] []
            ]
          ],
          div [] [button [] [text "fetch"]]
        ]
      ],

      p [] [text "New bookmark"],
      div [] [
        Html.form[] [
          div [] [
            label [] [
              text "title:",
              input [placeholder "Title", onInput UpdateNewBookmarkTitle] []
            ]
          ],
          div [] [
            label [] [
              text "description:",
              input [placeholder "Description", onInput UpdateNewBookmarkDescription] []
            ]
          ],
          div [] [button [] [text "create"]]
        ]
      ]

      -- div [] [text (interpolate "Title: {0}" [fetchedTitle])]
    ]

loginView : Model -> Html Msg
loginView model =
  Html.form [onSubmitWithPrevented StartsLoggingIn] [
    div [] [
      label [] [
        text "email:",
        input [type_ "email", placeholder "Your email", value model.newLogin.email, onInput UpdatesLoginEmail] []
      ]
    ],
    div [] [
      label [] [
        text "password:",
        input [type_ "password", placeholder "Your password", value model.newLogin.password, onInput UpdatesLoginPassword] []
      ]
    ],
    div [] [button [] [text "login"]]
  ]

onSubmitWithPrevented msg =
    Html.Events.custom "submit" (Decode.succeed { message = msg, stopPropagation = True, preventDefault = True })

viewLink : String -> Html msg
viewLink path =
  li [] [ a [ href path ] [ text path ] ]


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