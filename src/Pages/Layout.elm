module Pages.Layout exposing
    ( View
    , asDocument
    , mapMsg
    , new
    , withHeader
    )

import App.Header as AppHeader
import Browser
import Html exposing (div)
import Html.Attributes exposing (class)
import Session



-- タイトルのprefixなどアプリケーション画面のルールを統一するためにBrowser.Documentをラップした型
-- Appのview関数はこのView型を返すようにしているので必ず各画面もViewを返さねばらならない


type View msg
    = Plain (Browser.Document msg)
    | WithHeader Session.Session (Browser.Document msg)


new : Browser.Document msg -> View msg
new { title, body } =
    Plain
        { title = "Slip.it | " ++ title
        , body = body
        }


mapMsg : (a -> msg) -> View a -> View msg
mapMsg toMsg view =
    case view of
        WithHeader session { title, body } ->
            WithHeader
                session
                { title = title
                , body = List.map (Html.map toMsg) body
                }

        Plain { title, body } ->
            Plain
                { title = title
                , body = List.map (Html.map toMsg) body
                }


withHeader : Session.Session -> View msg -> View msg
withHeader session view =
    case view of
        Plain document ->
            WithHeader session document

        WithHeader _ document ->
            WithHeader session document


asDocument : (Session.Msg -> msg) -> View msg -> Browser.Document msg
asDocument sessionMsg view =
    case view of
        Plain document ->
            document

        WithHeader session { title, body } ->
            if Session.isLoggedIn session then
                { title = title
                , body =
                    [ AppHeader.view
                    , div
                        [ class "siimple-content siimple-content--extra-large" ]
                        [ Session.viewToasts sessionMsg session
                        , div [ class "siimple-grid" ] body
                        ]
                    ]
                }

            else
                { title = title
                , body = body
                }
