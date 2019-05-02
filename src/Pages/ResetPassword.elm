module Pages.ResetPassword exposing (Model, init, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Pages.Form.Email as Email exposing (Email)



-- Model


type alias Model =
    { email : Email }



-- Init


init : Model
init =
    { email = Email.empty }



-- View


view : Model -> Html msg
view model =
    div [] [ text "reset password" ]
