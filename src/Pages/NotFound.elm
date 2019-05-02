module Pages.NotFound exposing (Model, init, view)

import Flag exposing (Flag)
import Html exposing (..)
import Session exposing (Session)



------ Model ------


type alias Model =
    { flag : Flag
    , session : Session
    }



------ Init ------


init : Flag -> Session -> Model
init flag session =
    { flag = flag, session = session }



------ View ------


view : Html msg
view =
    div [] [ text "Not Found" ]
