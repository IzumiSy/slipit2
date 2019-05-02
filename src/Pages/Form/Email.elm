module Pages.Form.Email exposing (Email, empty, new)


type Email
    = Email String


new : String -> Email
new value =
    Email value


empty : Email
empty =
    Email ""
