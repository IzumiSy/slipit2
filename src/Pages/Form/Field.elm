module Pages.Form.Field exposing
    ( Field
    , blur
    , error
    , init
    , input
    , toString
    )

import Html exposing (Html)
import Html.Attributes exposing (value)
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


init : (String -> Result ( String, err ) String) -> String -> Field err
init validator value =
    Partial
        { value = value
        , validator = validator
        }


blur : Field err -> Field err
blur field =
    case field of
        Partial { value, validator } ->
            value
                |> validator
                |> mapResult field

        _ ->
            field


toString : Field err -> String
toString field =
    case field of
        Partial { value } ->
            value

        Valid { value } ->
            value

        Invalid { value } _ ->
            value


error : Field err -> Maybe err
error field =
    case field of
        Invalid _ err ->
            Just err

        _ ->
            Nothing



-- view


input : (Field err -> msg) -> msg -> List (Html.Attribute msg) -> Field err -> Html msg
input onInputMsg onBlurMsg attrs field =
    Html.input
        (List.append attrs
            [ value <| toString field
            , onBlur onBlurMsg
            , onInput
                (\value ->
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
                )
            ]
        )
        []



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
