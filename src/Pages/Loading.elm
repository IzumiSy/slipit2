module Pages.Loading exposing (view)

import Html exposing (div, text)
import Pages.Layout as Layout


view : Layout.View msg
view =
    Layout.new
        { title = "Loading"
        , body = [ div [] [ text "Loading..." ] ]
        }
