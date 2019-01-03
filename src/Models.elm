module Models exposing (..)

import Browser.Navigation as Nav
import Url


type alias Model =
  {
    navKey: Nav.Key,
    url: Url.Url,
    appConfig: AppConfig,
    newLogin: LoginForm,
    newBookmark: Bookmark,
    logInStatus: LoginStatus,
    titleFetchingStatus: TitleFetchingStatus
  }

type alias AppConfig =
  {
    functionUrl: String
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
  = NotLoggedIn
    | LoggingIn
    | LoggedIn (Result LoginError UserData)


type alias UserData =
  {
    bookmarks: List Bookmark,
    currentUser: User
  }


type alias User =
  {
    uid: String,
    email: String,
    displayName: Maybe String
  }


type alias NewBookmarkError =
  {
    message: String
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


type TitleFetchingStatus
  = TitleNotFetched
    | TitleFetching
    | TitleFetched (Result TitleFetchingError String)

type TitleFetchingError = TitleFetchingError String

unwrapTitleFetchingError : TitleFetchingError -> String
unwrapTitleFetchingError (TitleFetchingError msg) = msg
