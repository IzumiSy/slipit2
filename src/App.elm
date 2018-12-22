module App exposing (Msg, update, view, subscriptions, init)

import Models exposing (..)
import Ports exposing (..)
import Browser exposing (element)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as JD


-- Model


type alias Model =
  {
    bookmarks: List Bookmark,
    newBookmark: Bookmark,
    newLogin: LoginForm,
    logInStatus: LoginStatus,
    logInError: Maybe LoginError,
    currentUser: Maybe User
  }

init : () -> (Model, Cmd Msg)
init _ =
  (
    {
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


-- View
-- TODO: ログインエラーを表示する


view : Model -> Html Msg
view model =
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
      ]
    ]

onSubmitWithPrevented : msg -> Html.Attribute msg
onSubmitWithPrevented msg =
    Html.Events.custom "submit" (JD.succeed { message = msg, stopPropagation = True, preventDefault = True })


-- Subscription


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [
      logInFailed FailsLoggingIn,
      logInSucceeded SucceedsInLoggingIn
    ]


-- Main


main =
    element {
      init = init,
      view = view,
      update = update,
      subscriptions = subscriptions
    }