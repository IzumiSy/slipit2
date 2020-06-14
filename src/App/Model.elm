module App.Model exposing (Modelable)

import Flag
import Session


type alias Modelable a =
    { a
        | flag : Flag.Flag
        , session : Session.Session
    }
