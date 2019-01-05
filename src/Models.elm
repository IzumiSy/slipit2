module Models exposing (..)

import Browser.Navigation as Nav
import Url


type alias Model =
  {
    navKey: Nav.Key,
    url: Url.Url,
    appConfig: AppConfig,
    logInStatus: LoginStatus
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


type alias LoginError =
  {
    code: String,
    message: String
  }


type LoginStatus
  = NotLoggedIn LoginForm
    | LoggingIn
    | LoggedIn (Result LoginError UserData)


type alias InitialUserData =
  {
    bookmarks: List Bookmark,
    currentUser: User
  }

type alias UserData =
  {
    newBookmark: Bookmark,
    bookmarks: List Bookmark,
    currentUser: User,
    titleFetchingStatus: TitleFetchingStatus
  }

fromInitialUserData : InitialUserData -> UserData
fromInitialUserData initialUserData =
  {
    newBookmark = emptyBookmark (),
    bookmarks = initialUserData.bookmarks,
    currentUser = initialUserData.currentUser,
    titleFetchingStatus = TitleNotFetched
  }


type alias User =
  {
    uid: String,
    email: String,
    displayName: Maybe String
  }


type alias BookmarkCreatingError =
  {
    message: String
  }

type alias BookmarksFetchingError =
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
