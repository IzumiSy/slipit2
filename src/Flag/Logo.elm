module Flag.Logo exposing
    ( Logo
    , decode
    , empty
    , view
    )

import Html exposing (Html)
import Html.Attributes exposing (class, src)
import Json.Decode as Decode


type Logo
    = Logo String


empty : Logo
empty =
    Logo ""



-- view


view : Logo -> Html msg
view (Logo path) =
    Html.img [ class "image", src path ] []



-- decoder


decode : Decode.Decoder Logo
decode =
    Decode.andThen (Decode.succeed << Logo) Decode.string
