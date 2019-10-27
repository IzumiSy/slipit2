module App.Header exposing
    ( Msg(..)
    , update
    , view
    )

import App.Model as Model
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)



------ Msg ------


type Msg
    = Noop



------ Update ------


update : Msg -> Model.Modelable a -> ( Model.Modelable a, Cmd msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )



------ View ------


view : (Msg -> msg) -> Html msg
view toMsg =
    Html.map toMsg <|
        div
            [ class "siimple-navbar siimple-navbar--extra-large siimple-navbar--dark" ]
            [ div [ class "siimple-navbar-title" ] [ text "Slipit" ]
            ]
