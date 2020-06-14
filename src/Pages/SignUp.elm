module Pages.SignUp exposing (Model, Msg, init, update, view)

import App.Model as Model
import Flag
import Html exposing (..)
import Html.Attributes exposing (..)
import Pages.Form.Email as Email exposing (Email)
import Pages.Form.Password as Password exposing (Password)
import Pages.Layout as Layout
import Session exposing (Session)



-- model


type alias Model =
    Model.Modelable
        { email : Email
        , password : Password
        }


init : Flag.Flag -> Session -> ( Model, Cmd Msg )
init flag session =
    ( { email = Email.empty
      , password = Password.empty
      , flag = flag
      , session = session
      }
    , Cmd.none
    )



-- update


type Msg
    = SetEmail String
    | SetPassword String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



-- view


view : Model -> Layout.View Msg
view model =
    Layout.new
        { title = "Sign Up"
        , body = [ div [] [ text "signup" ] ]
        }
