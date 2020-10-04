module App.Header exposing
    ( Msg(..)
    , update
    , view
    )

import App.Model as Model
import Html exposing (Html, div, sup, text)
import Html.Attributes exposing (class)



-- update


type Msg
    = Noop


update : Msg -> Model.Modelable a -> ( Model.Modelable a, Cmd msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )



-- view


view : (Msg -> msg) -> Html msg
view toMsg =
    Html.map toMsg <|
        div
            [ class "siimple-navbar siimple-navbar--extra-large siimple-navbar--dark" ]
            [ div
                [ class "siimple-navbar-title header-title" ]
                [ text "Slip.it", sup [] [ text "beta" ] ]
            ]
