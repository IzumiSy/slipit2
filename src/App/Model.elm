module App.Model exposing (Flag, Modelable)

import Session


type alias Flag =
    { functionUrl : String
    , logoImagePath : String
    }


type alias Modelable a =
    { a
        | flag : Flag
        , session : Session.Session
    }
