module Pages.NewBookmark.Url exposing
    ( Url
    , isValid
    , new
    , unwrap
    , view
    )

import Html
import Html.Attributes exposing (placeholder, required, value)
import Html.Events exposing (onInput)
import Url as BuiltinUrl



-- なぜわざわざ組み込みのUrl型をラップしたオリジナルのUrl型を使っているかというと
-- ビルトインのものは常にValidなURL文字列のみしか保持できない構造になっているため
-- このUrl型では不正なURL文字列の場合にはプリミティブのString型でURLを保持できるようにしている
-- 入力過程の状態を保持するためには不完全なURL文字列も受け入れる必要がある


type Url
    = Valid BuiltinUrl.Url
    | Invalid String


new : String -> Url
new value =
    value
        |> BuiltinUrl.fromString
        |> Maybe.map Valid
        |> Maybe.withDefault (Invalid value)


unwrap : Url -> String
unwrap url =
    case url of
        Valid validUrl ->
            BuiltinUrl.toString validUrl

        Invalid value ->
            value


isValid : Url -> Bool
isValid url =
    case url of
        Valid _ ->
            True

        Invalid _ ->
            False



-- view


view : (Url -> msg) -> Url -> Html.Html msg
view onInput_ value_ =
    Html.input
        [ placeholder "URL"
        , required True
        , value <| unwrap value_
        , onInput (onInput_ << new)
        ]
        []
