module Models exposing (..)

import Browser.Navigation as Nav
import Url


type alias Model =
  {
    navKey: Nav.Key,
    url: Url.Url,
    appConfig: AppConfig,
    bookmarks: List Bookmark,
    newBookmark: Bookmark,
    fetchedWebPageTitle: Maybe String,
    newLogin: LoginForm,
    logInStatus: LoginStatus,
    logInError: Maybe LoginError,
    currentUser: Maybe User
  }

type alias AppConfig =
  {
    functionUrl: String
  }


type alias Bookmark =
  {
    url: String,
    title: String,
    description: String
  }

emptyBookmark _ = { url = "", title = "", description = "" }

setUrl v bookmark = { bookmark | url = v }

setTitle v bookmark = { bookmark | title = v }

setDescription v bookmark = { bookmark | description = v }


type alias BookmarkError =
  {
    message: String
  }


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


type alias ScrapingResult =
  {
    text: String,
    html: String
  }

{--
 type alias ScrapingResult =
  {
    text: String,
    html: String
  }
-}
