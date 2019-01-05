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


type alias LogInForm =
  {
    email: String,
    password: String,
    error: Maybe LoginError
  }

type alias LoginError =
  {
    code: String,
    message: String
  }

emptyLogin = { email = "", password = "", error = Nothing }

setError err login = { login | error = Just err }

type LoginStatus
  = NotLoggedIn LogInForm
    | LoggingIn
    | LoggedIn UserData


type alias InitialUserData =
  {
    bookmarks: List Bookmark,
    currentUser: User
  }

type alias UserData =
  {
    bookmarks: List Bookmark,
    currentUser: User,
    newBookmark: NewBookmarkForm,
    newBookmarkCreatingStatus: NewBookmarkCreatingStatus,
    titleFetchingStatus: TitleFetchingStatus
  }

fromInitialUserData : InitialUserData -> UserData
fromInitialUserData initialUserData =
  {
    bookmarks = initialUserData.bookmarks,
    currentUser = initialUserData.currentUser,
    newBookmark = emptyBookmark,
    newBookmarkCreatingStatus = NewBookmarkNotCreated,
    titleFetchingStatus = TitleNotFetched
  }


type alias User =
  {
    uid: String,
    email: String,
    displayName: Maybe String
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


type TitleFetchingStatus
  = TitleNotFetched
    | TitleFetching
    | TitleFetched (Result TitleFetchingError String)

type TitleFetchingError = TitleFetchingError String

unwrapTitleFetchingError : TitleFetchingError -> String
unwrapTitleFetchingError (TitleFetchingError msg) = msg


type alias NewBookmarkForm =
  {
    url: String,
    title: String,
    description: String
  }

emptyBookmark = { url = "", title = "", description = "" }

setUrl v bookmark = { bookmark | url = v }

setTitle v bookmark = { bookmark | title = v }

setDescription v bookmark = { bookmark | description = v }

type NewBookmarkCreatingStatus
  = NewBookmarkNotCreated
    | NewBookmarkCreating
    | NewBookmarkCreated (Result BookmarkCreatingError Bookmark)

type alias BookmarkCreatingError =
  {
    message: String
  }