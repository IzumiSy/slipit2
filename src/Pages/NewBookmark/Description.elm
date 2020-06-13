module Pages.NewBookmark.Description exposing
    ( Description
    , decode
    , empty
    , new
    , unwrap
    , view
    )

import Html
import Html.Attributes exposing (placeholder, value)
import Html.Events exposing (onInput)
import Json.Decode as Decode


type Description
    = Description String


new : String -> Description
new =
    Description


empty : Description
empty =
    Description ""


unwrap : Description -> String
unwrap (Description value) =
    value



-- view


view : (Description -> msg) -> Description -> Html.Html msg
view onInput_ (Description value_) =
    Html.input
        [ placeholder "Description"
        , value value_
        , onInput (onInput_ << Description)
        ]
        []



-- decoder


decode : Decode.Decoder Description
decode =
    Decode.andThen (Decode.succeed << Description) Decode.string
