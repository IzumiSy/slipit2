module Pages.Form.Email exposing (Email, empty, new, unwrap)


type Email
    = Email String


new : String -> Email
new value =
    Email value


unwrap : Email -> String
unwrap (Email value) =
    value


empty : Email
empty =
    Email ""
