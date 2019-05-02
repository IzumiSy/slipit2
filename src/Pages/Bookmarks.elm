module Pages.Bookmarks exposing (Model, Msg, view)

import Flag exposing (Flag)
import Html exposing (..)
import Html.Attributes exposing (..)
import Session exposing (Session)



------ Model ------


type alias Model =
    { flag : Flag
    , session : Session
    }



------ Msg ------


type Msg
    = Noop



------ View ------


view : Model -> Html msg
view model =
    div [] []
