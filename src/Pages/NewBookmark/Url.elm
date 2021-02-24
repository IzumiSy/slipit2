module Pages.NewBookmark.Url exposing
    ( Url
    , blur
    , empty
    , encode
    , error
    , new
    , unwrap
    , view
    )

import Html
import Html.Attributes exposing (class, placeholder, required)
import Json.Encode as Encode
import Pages.Form.Field as Field
import Url as BuiltinUrl


type Url
    = Url (Field.Field Error)


type Error
    = InvalidUrl
    | MustNotBeBlank
    | LengthTooLong


new : String -> Url
new value =
    value
        |> Field.init validator
        |> Url


empty : Url
empty =
    new ""


unwrap : Url -> String
unwrap (Url value) =
    Field.toString value


blur : Url -> Url
blur (Url value) =
    Url <| Field.blur value


error : Url -> Maybe Error
error (Url value) =
    Field.error value



-- view


view : (Url -> msg) -> msg -> Url -> Html.Html msg
view onInput onBlur (Url value) =
    Field.input
        (onInput << Url)
        onBlur
        [ placeholder "URL"
        , required True
        , class "siimple-input siimple-input--fluid"
        ]
        value



-- serialization


encode : Url -> Encode.Value
encode =
    Encode.string << unwrap



-- internals


validator : String -> Result ( String, Error ) String
validator value =
    if String.isEmpty value then
        Err ( value, MustNotBeBlank )

    else if String.length value > 100 then
        Err ( value, LengthTooLong )

    else
        value
            |> BuiltinUrl.fromString
            |> Maybe.map (\_ -> Ok value)
            |> Maybe.withDefault (Err ( value, InvalidUrl ))
