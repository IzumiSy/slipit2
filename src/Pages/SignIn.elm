module Pages.SignIn exposing (Model)

import Html exposing (..)
import Html.Attributes exposing (..)
import Pages.Form.Email as Email exposing (Email)
import Pages.Form.Password as Password exposing (Password)



-- Model


type alias Model =
    { email : Email
    , password : Password
    }



-- Init


init : Model
init =
    { email = Email.empty, password = Password.empty }



-- View


view : Model -> Html msg
view model =
    div [] [ text "signin" ]
