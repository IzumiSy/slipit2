module Toasts exposing (Toasts, init, view)

import Bookmark exposing (Bookmark)
import Html exposing (Html, div, text)
import Toasty



{- Bookmark作成／削除のタイミングで出てくるトーストの実装をに関するモジュール

   内部的にはToastyへ処理を移譲しているが、今後自前でトースト実装を作る場合には
   このモジュールだけに変更が閉じるようにしている。

-}


type Toast
    = Added Bookmark
    | Removed Bookmark
    | Updated Bookmark


type Toasts
    = Toasts (Toasty.Stack Toast)


init : Toasts
init =
    Toasts Toasty.initialState



-- view


view : (Toasty.Msg Toast -> msg) -> Toasts -> Html msg
view msg (Toasts toast) =
    Toasty.view config renderer msg toast



-- internals


renderer : Toast -> Html msg
renderer toast =
    case toast of
        Added _ ->
            div [] [ text "added!" ]

        Removed _ ->
            div [] [ text "edited!" ]

        Updated _ ->
            div [] [ text "updated!" ]


config : Toasty.Config msg
config =
    Toasty.config
        |> Toasty.transitionOutDuration 100
        |> Toasty.delay 8000
