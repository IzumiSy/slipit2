module Pages.NewBookmark.Description exposing
    ( Description
    , blur
    , decode
    , empty
    , error
    , new
    , unwrap
    , view
    )

import Html
import Html.Attributes exposing (placeholder)
import Json.Decode as Decode
import Pages.Form.Field as Field


type Description
    = Description (Field.Field Error)


type Error
    = MustNotBeBlank
    | LengthTooLong


new : String -> Description
new value =
    Description <| Field.init value validator


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
        [ placeholder "Description" ]
        value



-- decoder


decode : Decode.Decoder Description
decode =
    Decode.andThen (Decode.succeed << new) Decode.string



-- internals


validator : String -> Result ( String, Error ) String
validator value =
    if String.isEmpty value then
        Err ( value, MustNotBeBlank )

    else if String.length value > 200 then
        Err ( value, LengthTooLong )

    else
        Ok value
