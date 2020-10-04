module Toasts exposing
    ( Msg
    , Toast(..)
    , Toasts
    , add
    , init
    , update
    , view
    )

import Bookmark exposing (Bookmark)
import Html exposing (Html)
import Html.Attributes exposing (class, style)
import Toasty
import Toasty.Defaults as Defaults



{- Bookmark作成／削除のタイミングで出てくるトーストの実装をに関するモジュール

   内部的にはToastyへ処理を移譲しているが、今後自前でトースト実装を作る場合には
   このモジュールだけに変更が閉じるようにしている。

-}


type Toast
    = Added Bookmark
    | Removed Bookmark
    | Updated Bookmark
    | Error String


type Toasts
    = Toasts (Toasty.Stack Toast)


init : Toasts
init =
    Toasts Toasty.initialState


type Msg
    = Msg (Toasty.Msg Toast)


add : Toast -> (Msg -> msg) -> Toasts -> ( Toasts, Cmd msg )
add toast toMsg (Toasts value) =
    Tuple.mapFirst (\{ toasties } -> Toasts toasties) <|
        Toasty.addToastIfUnique config (Msg >> toMsg) toast ( { toasties = value }, Cmd.none )


update : (Msg -> msg) -> Msg -> Toasts -> ( Toasts, Cmd msg )
update toMsg (Msg msg) (Toasts value) =
    Tuple.mapFirst (\{ toasties } -> Toasts toasties) <|
        Toasty.update config (Msg >> toMsg) msg { toasties = value }



-- view


view : (Msg -> msg) -> Toasts -> Html msg
view msg (Toasts toast) =
    Toasty.view config renderer (Msg >> msg) toast



-- internals


renderer : Toast -> Html msg
renderer toast =
    case toast of
        Added _ ->
            Defaults.view <| Defaults.Success "Success" "New bookmark has Just been added!"

        Removed _ ->
            Defaults.view <| Defaults.Success "Success" "Bookmark has just been removed!"

        Updated _ ->
            Defaults.view <| Defaults.Success "Success" "Bookmark has just been updated!"

        Error err ->
            Defaults.view <| Defaults.Error "Error" err


config : Toasty.Config msg
config =
    Defaults.config
        |> Toasty.itemAttrs
            [ style "margin" "1.5em 1.5em 0 1.5em"
            , style "max-height" "100px"
            , style "transition" "max-height 0.6s, margin-top 0.6s"
            ]
        |> Toasty.transitionOutDuration 700
        |> Toasty.transitionOutAttrs
            [ class "animated fadeOutRightBig"
            , style "max-height" "0"
            , style "margin-top" "0.75em"
            ]
