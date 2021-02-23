module Pages.SignUp exposing (Model, Msg, init, update, view)

import App.Model as Model
import Flag
import Html exposing (..)
import Html.Attributes exposing (..)
import Pages.Layout as Layout
import Session exposing (Session)
import Typed exposing (Typed)



-- model


type alias Email =
    Typed EmailType String Typed.ReadWrite


type alias Password =
    Typed PasswordType String Typed.ReadWrite


type alias Model =
    Model.Modelable
        { email : Email
        , password : Password
        }


init : Flag.Flag -> Session -> ( Model, Cmd Msg )
init flag session =
    ( { email = Typed.new ""
      , password = Typed.new ""
      , flag = flag
      , session = session
      }
    , Cmd.none
    )



-- update


type Msg
    = SetEmail Email
    | SetPassword Password


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



-- internals


type EmailType
    = EmailType


type PasswordType
    = PasswordType
