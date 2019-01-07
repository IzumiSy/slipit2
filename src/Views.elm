module Views exposing (..)

import Msgs exposing (..)
import Models exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Decode
import String.Interpolate exposing(interpolate)
import Browser


-- View


view : Model -> Browser.Document Msg
view model =
  {
    title = "This is title",
    body =
      case model.logInStatus of
        NotLoggedIn form -> [loginView form model.appConfig.logoImagePath]
        LoggingIn -> [loadingView]
        LoggedIn userData -> [homeView userData]
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
    div [class "ui main container"] [
      h2 [class "ui dividing header"] [
        text (interpolate "Bookmarks ({0})" [String.fromInt (List.length userData.bookmarks)]),
        button [class "positive ui right floated small button"] [
          text "Add a new bookmark"
        ]
      ],

      div [class "ui four stackable cards bookmark-list"] (renderBookmarkItems userData.bookmarks),

      div [] [text (String.append "Current user: " currentUser.email)],
      div [] [button [onClick SignsOut] [text "sign out"]],

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

renderBookmarkItems : List Bookmark -> List (Html Msg)
renderBookmarkItems bookmarks =
  (List.map (\bookmark ->
    a [class "bookmark-item card", href bookmark.url] [
      div [class "main content"] [
        div [class "header"] [text bookmark.title],
        div [class "description"] [text bookmark.description]
      ],
      div [class "extra content"] [text bookmark.url]
    ] 
  ) bookmarks)

loadingView : Html Msg
loadingView =
  div [class "ui full height stackable grid"] [
    div [class "three column row"] [
      div [class "column"] [],
      div [class "column"] [
        div [class "ui active text loader"] [
          text "Loading..."
        ]
      ],
      div [class "column"] []
    ]
  ]

loginView : LogInForm -> String -> Html Msg
loginView form logoImagePath =
  div [class "login ui full height middle aligned center aligned grid"] [
    div [class "column"] [
      h2 [class "ui grey image header"] [
        img [class "image", src logoImagePath] [],
        div [class "content"] [
          text "Log in to Slip.it",
          h5 [] [text "Your online bookmarks never be social."]
        ] 
      ],
      Html.form [onSubmitWithPrevented StartsLoggingIn, class "ui large warning form"] [
        div [class "ui stackable grid"] [
          div [class "three column row"] [
            div [class "column"] [],
            div [class "column"] [
              div [class "ui segment"] [
                Maybe.withDefault (div [] []) (
                  Maybe.map (\err -> 
                    div [class "ui warning message"] [
                      div [class "header"] [
                        div [] [text err.message]
                      ]
                    ]
                  ) form.error
                ),
                div [class "field"] [
                  div [class "ui left icon input"] [
                    i [class "user icon"] [],
                    input [type_ "email", placeholder "Your email", required True, value form.email, onInput UpdatesLoginEmail] []
                  ]
                ],
                div [class "field"] [
                  div [class "ui left icon input"] [
                    i [class "lock icon"] [],
                    input [type_ "password", placeholder "Your password", required True, value form.password, onInput UpdatesLoginPassword] []
                  ]
                ],
                button [class "ui fluid large teal submit button"] [text "login"]
              ],
              div [class "ui message registration"] [
                text "New to Slip.it?",
                viewLink "sign_up" "Create a new account"
              ],
              div [class "ui password"] [
                viewLink "reset_password" "Forgot your own password?"
              ],
              div [class "ui disabled header"] [
                h5 [] [text "© 2019 IzumiSy."]
              ]
            ],
            div [class "column"] []
          ]
        ]
      ]
    ]
  ]

onSubmitWithPrevented msg =
    Html.Events.custom "submit" (Decode.succeed { message = msg, stopPropagation = True, preventDefault = True })

viewLink : String -> String -> Html msg
viewLink path title =
  a [ href path ] [ text title ]