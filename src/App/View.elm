module App.View exposing
    ( AppView
    , asDocument
    , mapMsg
    , new
    )

import Browser
import Html



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


asDocument : AppView msg -> Browser.Document msg
asDocument (AppView document) =
    document
