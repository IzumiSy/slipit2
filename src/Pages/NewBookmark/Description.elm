module Pages.NewBookmark.Description exposing
    ( Description
    , blur
    , decode
    , empty
    , encode
    , error
    , new
    , unwrap
    , view
    )

import Html
import Html.Attributes exposing (class, placeholder)
import Json.Decode as Decode
import Json.Encode as Encode
import Pages.Form.Field as Field


type Description
    = Description (Field.Field Error)


type Error
    = MustNotBeBlank
    | LengthTooLong


new : String -> Description
new value =
    value
        |> Field.init validator
        |> Description


empty : Description
empty =
    new ""


unwrap : Description -> String
unwrap (Description value) =
    Field.toString value


blur : Description -> Description
blur (Description value) =
    Description <| Field.blur value


error : Description -> Maybe Error
error (Description value) =
    Field.error value



-- view


view : (Description -> msg) -> msg -> Description -> Html.Html msg
view onInput onBlur (Description value) =
    Field.input
        (onInput << Description)
        onBlur
        [ placeholder "Description"
        , class "siimple-input siimple-input--fluid"
        ]
        value



-- serialization


decode : Decode.Decoder Description
decode =
    Decode.andThen (Decode.succeed << new << Maybe.withDefault "") (Decode.nullable Decode.string)


encode : Description -> Encode.Value
encode =
    Encode.string << unwrap



-- internals


validator : String -> Result ( String, Error ) String
validator value =
    if String.isEmpty value then
        Err ( value, MustNotBeBlank )

    else if String.length value > 200 then
        Err ( value, LengthTooLong )

    else
        Ok value
