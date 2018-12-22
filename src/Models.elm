module Models exposing (..)


type alias Bookmark =
  {
    url: String,
    title: String,
    description: String
  }

newBookmark (url, title, description) = { url = url, title = title, description = description }

emptyBookmark _ = { url = "", title = "", description = "" }

setUrl v bookmark = { bookmark | url = v }

setTitle v bookmark = { bookmark | title = v }

setDescription v bookmark = { bookmark | description = v }


type alias LoginForm =
  {
    email: String,
    password: String
  }

emptyLogin _ = { email = "", password = "" }

setEmail v login = { login | email = v }

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