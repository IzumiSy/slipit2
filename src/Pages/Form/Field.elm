module Pages.Form.Field exposing (Field, blur, init, input)

import Html exposing (Html)
import Html.Attributes exposing (class, type_, value)
import Html.Events exposing (onBlur, onInput)



-- 入力フォームにおいてバリデーション基盤を提供する抽象モジュール


type alias Common err =
    { value : String
    , validator : String -> Result ( String, err ) String
    }


type Field err
    = Partial (Common err)
    | Valid (Common err)
    | Invalid (Common err) err


init : String -> (String -> Result ( String, err ) String) -> Field err
init value validator =
    Partial
        { value = value
        , validator = validator
        }



-- view


input : (Field err -> msg) -> msg -> Field err -> Html msg
input onInputMsg onBlurMsg field =
    let
        onInputHandler =
            \value ->
                onInputMsg <|
                    case field of
                        Partial { validator } ->
                            Partial
                                { value = value
                                , validator = validator
                                }

                        Valid { validator } ->
                            value
                                |> validator
                                |> mapResult field

                        Invalid { validator } _ ->
                            value
                                |> validator
                                |> mapResult field
    in
    Html.input
        [ class "input"
        , type_ "text"
        , value <| toString field
        , onBlur onBlurMsg
        , onInput onInputHandler
        ]
        []


blur : Field err -> Field err
blur field =
    case field of
        Partial { value, validator } ->
            value
                |> validator
                |> mapResult field

        _ ->
            field



-- internals


mapResult : Field err -> Result ( String, err ) String -> Field err
mapResult field result =
    let
        validator_ =
            case field of
                Partial { validator } ->
                    validator

                Valid { validator } ->
                    validator

                Invalid { validator } _ ->
                    validator
    in
    case result of
        Ok value ->
            Valid
                { value = value
                , validator = validator_
                }

        Err ( value, err ) ->
            Invalid
                { value = value
                , validator = validator_
                }
                err


toString : Field err -> String
toString field =
    case field of
        Partial { value } ->
            value

        Valid { value } ->
            value

        Invalid { value } _ ->
            value
