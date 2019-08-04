module App.Header exposing
    ( Msg(..)
    , view
    )

import Browser
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Session



-- Msg


type Msg
    = Noop



-- View


view : (Msg -> msg) -> Html msg
view toMsg =
    Html.map toMsg <|
        div
            [ class "siimple-navbar siimple-navbar--extra-large siimple-navbar--dark" ]
            [ div [ class "siimple-navbar-title" ] [ text "Slipit" ]
            , div [ onClick Noop ] []
            ]
