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
        NotLoggedIn form -> [loginView form]
        LoggingIn -> [loadingView]
        LoggedIn result ->
          case result of
            -- Errの場合ではここではなくUpdate側でログイン画面に戻るMsgを発行する
            Ok userData -> [homeView userData]
            Err _ -> [loadingView]
  }

homeView : UserData -> Html Msg
homeView userData =
  let
    titleFetchingErrorM =
      case userData.titleFetchingStatus of
        TitleFetched result ->
          case result of
            Err err -> Just (String.append "Error: " (unwrapTitleFetchingError err))
            _ -> Nothing
        _ -> Nothing
    fetchButtonText =
      case userData.titleFetchingStatus of
        TitleFetching -> "Fetching..."
        _ -> "Fetch"
    currentUser = userData.currentUser
  in
    div [] [
      div [] [text (String.append "Current user: " currentUser.email)],
      div [] [button [onClick SignsOut] [text "sign out"]],

      div [] [
        p [] [text "Your bookmarks"],
        ul [] (
          List.map (\bookmark ->
            li [] [text bookmark.title] 
          ) userData.bookmarks 
        )
      ],

      div [] [
        p [] [text "New bookmark"],
        Html.form [onSubmitWithPrevented CreatesNewbookmark] [
          div [] [
            label [] [
              text "url:",
              input [placeholder "Url to bookmark", required True, value userData.newBookmark.url, onInput UpdateNewBookmarkUrl] []
            ]
          ],
          div [] [
            label [] [
              text "title:",
              input [placeholder "Title", value userData.newBookmark.title, onInput UpdateNewBookmarkTitle] []
            ]
          ],
          div [] [
            label [] [
              text "description:",
              input [placeholder "Description", value userData.newBookmark.description, onInput UpdateNewBookmarkDescription] []
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

loadingView : Html Msg
loadingView =
  div [] [
    text "logging in..."
  ]

-- TODO: ログインエラーの文言を表示する
loginView : LoginForm -> Html Msg
loginView form =
  Html.form [onSubmitWithPrevented StartsLoggingIn] [
    div [] [
      label [] [
        text "email:",
        input [type_ "email", placeholder "Your email", required True, value form.email, onInput UpdatesLoginEmail] []
      ]
    ],
    div [] [
      label [] [
        text "password:",
        input [type_ "password", placeholder "Your password", required True, value form.password, onInput UpdatesLoginPassword] []
      ]
    ],
    div [] [button [] [text "login"]]
  ]

onSubmitWithPrevented msg =
    Html.Events.custom "submit" (Decode.succeed { message = msg, stopPropagation = True, preventDefault = True })

viewLink : String -> Html msg
viewLink path =
  li [] [ a [ href path ] [ text path ] ]