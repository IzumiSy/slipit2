module App exposing (Msg, update, view, subscriptions, init)

import Models exposing (..)
import Ports exposing (..)
import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as JD
import Url


-- Model


type alias Model =
  {
    navKey: Nav.Key,
    url: Url.Url,
    bookmarks: List Bookmark,
    newBookmark: Bookmark,
    newLogin: LoginForm,
    logInStatus: LoginStatus,
    logInError: Maybe LoginError,
    currentUser: Maybe User
  }

init : () -> Url.Url -> Nav.Key -> (Model, Cmd Msg)
init _ url navKey =
  (
    {
      navKey = navKey,
      url = url,
      bookmarks = [],
      newBookmark = emptyBookmark (),
      newLogin = emptyLogin (),
      logInStatus = NotLoggedIn,
      logInError = Nothing,
      currentUser = Nothing
    },
    Cmd.none
  )


-- Msg
-- メッセージはステートの変更をトリガするものなので全て命名は命令形にする
-- また、主語はアプリケーション自身なので原型の三人称単数現在形とする


type Msg =
  UpdatesLoginEmail String
  | UpdatesLoginPassword String
  | StartsLoggingIn
  | SucceedsInLoggingIn User
  | FailsLoggingIn LoginError
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
    SucceedsInLoggingIn user ->
      ({ model | logInStatus = LogInSucceeded, currentUser = Just user }, Cmd.none)
    FailsLoggingIn err ->
      ({ model | logInStatus = LogInFailed, logInError = Just err }, Cmd.none)

    LinkClicked urlRequest ->
      case urlRequest of
        Browser.Internal url ->
          (model, Nav.pushUrl model.navKey (Url.toString url))
        Browser.External href ->
          (model, Nav.load href)
    UrlChanged url ->
      ({ model | url = url}, Cmd.none)


-- View
-- TODO: ログインエラーを表示する


view : Model -> Browser.Document Msg
view model =
  {
    title = "This is title",
    body = [
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
        div [] [
          button [] [text "login"]
        ],
        div [] [
          viewLink "/home"
        ]
      ]
    ]
  }

onSubmitWithPrevented msg =
    Html.Events.custom "submit" (JD.succeed { message = msg, stopPropagation = True, preventDefault = True })


viewLink : String -> Html msg
viewLink path =
  li [] [ a [ href path ] [ text path ] ]


-- Subscription


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [
      logInFailed FailsLoggingIn,
      logInSucceeded SucceedsInLoggingIn
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