module Views exposing (..)

import Msgs exposing (..)
import Models exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Decode
import Browser


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
        Html.form [onSubmitWithPrevented StartFetchingWebPageTitle] [
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
        Html.form [onSubmitWithPrevented CreatesNewbookmark] [
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