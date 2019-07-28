module Pages.Loading exposing (view)

import App.View as View
import Html exposing (..)


view : View.AppView msg
view =
    View.new
        { title = "Loading"
        , body = [ div [] [ text "Loading..." ] ]
        }
