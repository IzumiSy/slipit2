module Pages.NotFound exposing (view)

import App.View as View
import Html exposing (..)


view : View.AppView msg
view =
    View.new
        { title = "Not Found"
        , body = [ div [] [ text "Not Found" ] ]
        }
