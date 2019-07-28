module Pages.ResetPassword exposing (Model, Msg, init, update, view)

import App.Model as Model
import App.View as View
import Html exposing (..)
import Html.Attributes exposing (..)
import Pages.Form.Email as Email exposing (Email)
import Session exposing (Session)



-- Model


type alias Model =
    Model.Modelable { email : Email }



-- Msg


type Msg
    = SetEmail String



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



-- Init


init : Model.Flag -> Session -> Model
init flag session =
    { email = Email.empty
    , flag = flag
    , session = session
    }



-- View


view : Model -> View.AppView msg
view model =
    View.new
        { title = "Password Reset"
        , body = [ div [] [ text "reset password" ] ]
        }
