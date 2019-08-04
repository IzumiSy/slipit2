module App.View exposing
    ( AppView
    , asDocument
    , mapMsg
    , new
    , withHeader
    )

import Browser
import Html exposing (div, text)
import Html.Attributes exposing (class)
import Session



-- タイトルのprefixなどアプリケーション画面のルールを統一するためにBrowser.Documentをラップした型
-- Appのview関数はAppViewを返すようにしているので必ず各画面はAppViewを返さねばらならない


type AppView msg
    = AppView (Browser.Document msg)


new : Browser.Document msg -> AppView msg
new { title, body } =
    AppView
        { title = "Slip.it | " ++ title
        , body = body
        }


mapMsg : (a -> msg) -> AppView a -> AppView msg
mapMsg toMsg (AppView { title, body }) =
    AppView
        { title = title
        , body = List.map (Html.map toMsg) body
        }


withHeader : Session.Session -> AppView msg -> AppView msg
withHeader session (AppView { title, body }) =
    if Session.isLoggedIn session then
        AppView
            { title = title
            , body =
                [ div
                    [ class "siimple-navbar siimple-navbar--extra-large siimple-navbar--dark" ]
                    [ div [ class "siimple-navbar-title" ] [ text "Slipit" ]
                    ]
                , div
                    [ class "siimple-content siimple-content--extra-large" ]
                    [ div [ class "siimple-grid" ] body
                    ]
                ]
            }

    else
        AppView
            { title = title
            , body = body
            }


asDocument : AppView msg -> Browser.Document msg
asDocument (AppView document) =
    document
