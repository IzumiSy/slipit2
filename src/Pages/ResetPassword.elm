module Pages.ResetPassword exposing (Model, Msg, init, update, view)

import App.Header as AppHeader
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


type alias Model =
    Model.Modelable { email : Email }


init : Flag.Flag -> Session -> ( Model, Cmd Msg )
init flag session =
    ( { email = Typed.new ""
      , flag = flag
      , session = session
      }
    , Cmd.none
    )



-- update


type Msg
    = SetEmail Email


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetEmail _ ->
            ( model, Cmd.none )



-- view


view : Model -> Layout.View msg
view model =
    Layout.new
        { title = "Password Reset"
        , body = [ div [] [ text "reset password" ] ]
        }



-- internals


type EmailType
    = EmailType
