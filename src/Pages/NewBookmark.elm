module Pages.NewBookmark exposing (Model, Msg, init, view)

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



------ Init ------


init : Flag -> Session -> Model
init flag session =
    { flag = flag
    , session = session
    }



------ View ------


view : Model -> Html msg
view model =
    div [] [ text "new bookmark" ]
