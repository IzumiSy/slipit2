module Pages.NotFound exposing (view)

import App.Header as AppHeader
import Html exposing (..)
import Pages.Layout as Layout


view : Layout.View msg
view =
    Layout.new
        { title = "Not Found"
        , body = [ div [] [ text "Not Found" ] ]
        }
