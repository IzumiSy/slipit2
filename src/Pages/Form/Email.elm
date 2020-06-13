module Pages.Form.Email exposing (Email, empty, new, toString, view)

import Html exposing (Attribute, Html)
import Html.Attributes exposing (placeholder, required, type_, value)
import Html.Events exposing (onInput)


type Email
    = Email String


new : String -> Email
new value =
    Email value


toString : Email -> String
toString (Email value) =
    value


empty : Email
empty =
    Email ""



-- view


view : (Email -> msg) -> List (Attribute msg) -> Email -> Html msg
view onInput_ attr email =
    Html.input
        (List.append
            attr
            [ type_ "email"
            , placeholder "Your email"
            , required True
            , value <| toString email
            , onInput (onInput_ << new)
            ]
        )
        []
