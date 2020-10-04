module App.Header exposing (view)

import Html exposing (Html, div, sup, text)
import Html.Attributes exposing (class)



-- view


view : Html msg
view =
    div
        [ class "siimple-navbar siimple-navbar--extra-large siimple-navbar--dark" ]
        [ div
            [ class "siimple-navbar-title header-title" ]
            [ text "Slip.it", sup [] [ text "beta" ] ]
        ]
