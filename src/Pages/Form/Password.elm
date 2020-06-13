module Pages.Form.Password exposing (Password, empty, new, toString, view)

import Html exposing (Attribute, Html)
import Html.Attributes exposing (placeholder, required, type_, value)
import Html.Events exposing (onInput)


type Password
    = Password String


new : String -> Password
new value =
    Password value


toString : Password -> String
toString (Password value) =
    value


empty : Password
empty =
    Password ""



-- view


view : (Password -> msg) -> List (Attribute msg) -> Password -> Html msg
view onInput_ attr password =
    Html.input
        (List.append
            attr
            [ type_ "password"
            , placeholder "Your password"
            , required True
            , value <| toString password
            , onInput (onInput_ << new)
            ]
        )
        []
