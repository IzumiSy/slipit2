module Pages.Loading exposing (view)

import App.Header as AppHeader
import Html exposing (..)
import Pages.Layout as Layout


view : Layout.View msg
view =
    Layout.new
        { title = "Loading"
        , body = [ div [] [ text "Loading..." ] ]
        }
