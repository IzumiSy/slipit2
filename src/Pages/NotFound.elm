module Pages.NotFound exposing (view)

import Html exposing (div, text)
import Pages.Layout as Layout


view : Layout.View msg
view =
    Layout.new
        { title = "Not Found"
        , body = [ div [] [ text "Not Found" ] ]
        }
