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
    title = "Slip.it",
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
      case userData.urlFetchingStatus of
        UrlFetched fetchedResult ->
          case fetchedResult of
            Err err -> Just (String.append "Error: " (unwrapUrlFetchingError err))
            _ -> Nothing
        _ -> Nothing
    fetchButtonText =
      case userData.urlFetchingStatus of
        UrlFetching -> "Fetching..."
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
  div [class "siimple-grid"] [
    div [class "siimple-grid-row"] [
      div [class "siimple-grid-col siimple-grid-col--4 siimple-grid-col--xl-3 siimple-grid-col--md-1 siimple-grid-col--sm-12-hide"] [],
      div [class "siimple-grid-col siimple-grid-col--4 siimple-grid-col--xl-6 siimple-grid-col--md-10 siimple-grid-col--sm-12"] [
        div [class "login"] [
          h2 [class "login-header"] [
            img [class "image", src logoImagePath] [],
            div [class "content centered-xs"] [
              text "Log in to Slip.it",
              h5 [] [text "Your online bookmarks never be social."]
            ] 
          ],
          Html.form [onSubmitWithPrevented StartsLoggingIn, class "siimple-form login-fields"] [
            Maybe.withDefault (div [] []) (
              Maybe.map (\err -> 
                div [class "siimple-alert siimple-alert--warning"] [text err.message]
              ) form.error
            ),
            div [class "siimple-form-field"] [
              div [class "siimple-form-field-label"] [text "E-mail"],
              input [type_ "email", class "siimple-input siimple-input--fluid", placeholder "Your email", required True, value form.email, onInput UpdatesLoginEmail] []
            ],
            div [class "siimple-form-field"] [
              div [class "siimple-form-field-label"] [text "Password"],
              input [type_ "password", class "siimple-input siimple-input--fluid", placeholder "Your password", required True, value form.password, onInput UpdatesLoginPassword] []
            ],
            div [class "siimple-form-field"] [
              button [class "siimple-btn siimple-btn--teal siimple-btn--fluid"] [text "Login"]
            ]
          ],
          div [class "siimple-grid-row siimple--text-center"] [
            div [class "signup-guidance"] [
              text "New to Slip.it?",
              viewLink "sign_up" "Create a new account"
            ],
            div [] [
              viewLink "reset_password" "Forgot your own password?"
            ],
            div [] [
              h5 [] [text "© 2019 IzumiSy."]
            ]
          ]
        ]
      ],
      div [class "siimple-grid-col siimple-grid-col--4 siimple-grid-col--xl-3 siimple-grid-col--md-1 siimple-grid-col--sm-12-hide"] []
    ]
  ]

onSubmitWithPrevented msg =
    Html.Events.custom "submit" (Decode.succeed { message = msg, stopPropagation = True, preventDefault = True })

viewLink : String -> String -> Html msg
viewLink path title =
  a [ href path ] [ text title ]