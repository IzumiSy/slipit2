module Pages.NewBookmark.Url exposing
    ( Url
    , empty
    , isValid
    , new
    , unwrap
    )

import Url



-- なぜわざわざ組み込みのUrl型をラップしたオリジナルのUrl型を使っているかというと
-- ビルトインのものは常にValidなURL文字列のみしか保持できない構造になっているため
-- このUrl型では不正なURL文字列の場合にはプリミティブのString型でURLを保持できるようにしている
-- 入力過程の状態を保持するためには不完全なURL文字列も受け入れる必要がある


type Url
    = Valid Url.Url
    | Invalid String


new : String -> Url
new value =
    value
        |> Url.fromString
        |> Maybe.map Valid
        |> Maybe.withDefault (Invalid value)


unwrap : Url -> Result String String
unwrap url =
    case url of
        Valid validUrl ->
            Ok <| Url.toString <| validUrl

        Invalid value ->
            Err value


empty : Url
empty =
    Invalid ""


isValid : Url -> Bool
isValid url =
    case url of
        Valid _ ->
            True

        Invalid _ ->
            False
