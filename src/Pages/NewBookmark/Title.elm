module Pages.NewBookmark.Title exposing
    ( Title
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


type Title
    = Title (Field.Field Error)


type Error
    = MustNotBeBlank
    | LengthTooLong


new : String -> Title
new value =
    value
        |> Field.init validator
        |> Title


empty : Title
empty =
    new ""


unwrap : Title -> String
unwrap (Title value) =
    Field.toString value


blur : Title -> Title
blur (Title value) =
    Title <| Field.blur value


error : Title -> Maybe Error
error (Title value) =
    Field.error value



-- view


view : (Title -> msg) -> msg -> Title -> Html.Html msg
view onInput onBlur (Title value) =
    Field.input
        (onInput << Title)
        onBlur
        [ placeholder "Title" ]
        value



-- decoder


decode : Decode.Decoder Title
decode =
    Decode.andThen (Decode.succeed << new) Decode.string



-- internals


validator : String -> Result ( String, Error ) String
validator value =
    if String.isEmpty value then
        Err ( value, MustNotBeBlank )

    else if String.length value > 100 then
        Err ( value, LengthTooLong )

    else
        Ok value
