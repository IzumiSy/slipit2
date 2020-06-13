module Pages.NewBookmark.Title exposing
    ( Title
    , decode
    , empty
    , view
    , new
    , unwrap
    )

import Html
import Html.Attributes exposing (placeholder, value)
import Html.Events exposing (onInput)
import Json.Decode as Decode


type Title
    = Title String


new : String -> Title
new =
    Title


unwrap : Title -> String
unwrap (Title value) =
    value


empty : Title
empty =
    Title ""



-- view


view : (Title -> msg) -> Title -> Html.Html msg
view onInput_ (Title value_) =
    Html.input
        [ placeholder "Title"
        , value value_
        , onInput (onInput_ << Title)
        ]
        []



-- decoder


decode : Decode.Decoder Title
decode =
    Decode.andThen (Decode.succeed << Title) Decode.string
