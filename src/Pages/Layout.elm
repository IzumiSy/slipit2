module Pages.Layout exposing
    ( View
    , asDocument
    , mapMsg
    , new
    , withHeader
    )

import App.Header as AppHeader
import Browser
import Html exposing (div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Session


type
    View msg
    -- タイトルのprefixなどアプリケーション画面のルールを統一するためにBrowser.Documentをラップした型
    -- Appのview関数はAppViewを返すようにしているので必ず各画面はAppViewを返さねばらならない
    = Plain (Browser.Document msg)
    | WithHeader Session.Session (AppHeader.Msg -> msg) (Browser.Document msg)


new : Browser.Document msg -> View msg
new { title, body } =
    Plain
        { title = "Slip.it | " ++ title
        , body = body
        }


mapMsg : (a -> msg) -> View a -> View msg
mapMsg toMsg view =
    case view of
        Plain { title, body } ->
            Plain
                { title = title
                , body = List.map (Html.map toMsg) body
                }

        WithHeader session toHeaderMsg { title, body } ->
            WithHeader
                session
                toHeaderMsg
                { title = title
                , body = List.map (Html.map toMsg) body
                }


withHeader : Session.Session -> (AppHeader.Msg -> msg) -> View msg -> View msg
withHeader session toHeaderMsg view =
    case view of
        Plain document ->
            WithHeader session toHeaderMsg document

        WithHeader _ _ document ->
            WithHeader session toHeaderMsg document


asDocument : View msg -> Browser.Document msg
asDocument view =
    case view of
        Plain document ->
            document

        WithHeader session toMsg { title, body } ->
            if Session.isLoggedIn session then
                { title = title
                , body =
                    [ AppHeader.view toMsg
                    , div
                        [ class "siimple-content siimple-content--extra-large" ]
                        [ div [ class "siimple-grid" ] body
                        ]
                    ]
                }

            else
                { title = title
                , body = body
                }
