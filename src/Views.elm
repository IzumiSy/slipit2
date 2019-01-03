module Views exposing (..)

import Msgs exposing (..)
import Models exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Decode
import Browser


-- View


view : Model -> Browser.Document Msg
view model =
  {
    title = "This is title",
    body =
      case model.logInStatus of
        NotLoggedIn -> [loginView model]
        LoggingIn -> [loginView model]
        LoggedIn result ->
          case result of
            Ok userData -> [homeView userData model]
            Err err -> [loginView model]
  }

homeView : UserData -> Model -> Html Msg
homeView userData model =
  let
    titleFetchingErrorM =
      case model.titleFetchingStatus of
        TitleFetched result ->
          case result of
            Err err -> Just (String.append "Error: " (unwrapTitleFetchingError err))
            _ -> Nothing
        _ -> Nothing
    fetchButtonText =
      case model.titleFetchingStatus of
        TitleFetching -> "Fetching..."
        _ -> "Fetch"
    currentUser = userData.currentUser
  in
    div [] [
      div [] [text (String.append "Current user: " currentUser.email)],
      div [] [button [onClick SignsOut] [text "sign out"]],

      p [] [text "New bookmark"],
      div [] [
        Html.form [onSubmitWithPrevented CreatesNewbookmark] [
          div [] [
            label [] [
              text "url:",
              input [placeholder "Url to bookmark", required True, value model.newBookmark.url, onInput UpdateNewBookmarkUrl] []
            ]
          ],
          div [] [
            label [] [
              text "title:",
              input [placeholder "Title", value model.newBookmark.title, onInput UpdateNewBookmarkTitle] []
            ]
          ],
          div [] [
            label [] [
              text "description:",
              input [placeholder "Description", value model.newBookmark.description, onInput UpdateNewBookmarkDescription] []
            ]
          ],
          div [] [
            div [] [
              button [type_ "button", onClick StartFetchingWebPageTitle] [text fetchButtonText]
            ],
            div [] [button [type_ "submit"] [text "create"]]
          ]
        ]
      ]

      -- div [] [text (interpolate "Title: {0}" [fetchedTitle])]
    ]

-- TODO: ログインエラーの文言を表示する
loginView : Model -> Html Msg
loginView model =
  let
    loggingIn =
      case model.logInStatus of
        LoggingIn -> True
        _ -> False
  in
    Html.form [onSubmitWithPrevented StartsLoggingIn] [
      div [] [
        label [] [
          text "email:",
          input [type_ "email", placeholder "Your email", required True, value model.newLogin.email, onInput UpdatesLoginEmail] []
        ]
      ],
      div [] [
        label [] [
          text "password:",
          input [type_ "password", placeholder "Your password", required True, value model.newLogin.password, onInput UpdatesLoginPassword] []
        ]
      ],
      div [] [button [disabled loggingIn] [text (if loggingIn then "logging in..." else "login")]]
    ]

onSubmitWithPrevented msg =
    Html.Events.custom "submit" (Decode.succeed { message = msg, stopPropagation = True, preventDefault = True })

viewLink : String -> Html msg
viewLink path =
  li [] [ a [ href path ] [ text path ] ]