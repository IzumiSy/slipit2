module Toasts exposing (Toasts, init, view)

import Bookmark exposing (Bookmark)
import Html exposing (Html, div)
import Toasty



{- Bookmark作成／削除のタイミングで出てくるトーストの実装をに関するモジュール

   内部的にはToastyへ処理を移譲しているが、今後自前でトースト実装を作る場合には
   このモジュールだけに変更が閉じるようにしている。

-}


type Toasts
    = Toasts (Toasty.Stack Bookmark)


init : Toasts
init =
    Toasts Toasty.initialState



-- view


view : (Toasty.Msg Bookmark -> msg) -> Toasts -> Html msg
view msg (Toasts toasty) =
    Toasty.view config renderer msg toasty



-- internals


renderer : Bookmark -> Html msg
renderer _ =
    div [] []


config : Toasty.Config msg
config =
    Toasty.config
        |> Toasty.transitionOutDuration 100
        |> Toasty.delay 8000
