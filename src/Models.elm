module Models exposing (..)


type alias Bookmark =
  {
    url: String,
    title: String,
    description: String
  }

newBookmark : (String, String, String) -> Bookmark
newBookmark (url, title, description) = { url = url, title = title, description = description }

emptyBookmark : () -> Bookmark
emptyBookmark _ = { url = "", title = "", description = "" }

setUrl : String -> Bookmark -> Bookmark
setUrl v bookmark = { bookmark | url = v }

setTitle : String -> Bookmark -> Bookmark
setTitle v bookmark = { bookmark | title = v }

setDescription : String -> Bookmark -> Bookmark
setDescription v bookmark = { bookmark | description = v }


type alias LoginForm =
  {
    email: String,
    password: String
  }

emptyLogin : () -> LoginForm
emptyLogin _ = { email = "", password = "" }

setEmail : String -> LoginForm -> LoginForm
setEmail v login = { login | email = v }

setPassword : String -> LoginForm -> LoginForm
setPassword v login = { login | password = v }


type alias LoginError =
  {
    code: String,
    message: String
  }


type LoginStatus
  = NotLoggedIn | LoggingIn | LogInSucceeded | LogInFailed


type alias User =
  {
    uid: String,
    email: String,
    displayName: Maybe String
  }