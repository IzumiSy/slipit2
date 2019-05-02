module Pages.Form.Password exposing (Password, empty, new, unwrap)


type Password
    = Password String


new : String -> Password
new value =
    Password value


unwrap : Password -> String
unwrap (Password value) =
    value


empty : Password
empty =
    Password ""
