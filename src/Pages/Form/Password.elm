module Pages.Form.Password exposing (Password, empty, new)


type Password
    = Password String


new : String -> Password
new value =
    Password value


empty : Password
empty =
    Password ""
