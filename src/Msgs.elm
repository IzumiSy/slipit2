module Msgs exposing (..)

import Models exposing (..)
import Html exposing (..)
import Browser
import Http
import Url


type Msg =
  UpdatesLoginEmail String
  | UpdatesLoginPassword String
  | StartsLoggingIn
  | SucceedsInLoggingIn InitialUserData
  | FailsLoggingIn LogInForm
  | SignsOut
  | SignedOut ()
  | UpdateNewBookmarkUrl String
  | UpdateNewBookmarkTitle String
  | UpdateNewBookmarkDescription String
  | CreatesNewbookmark
  | CreatingNewBookmarkSucceeded Bookmark
  | CreatingNewBookmarkFailed BookmarkCreatingError
  | FetchingBookmarksSucceeded (List Bookmark)
  | FetchingBookmarksFailed BookmarksFetchingError
  | StartFetchingWebPageTitle
  | WebPageTitleFetched (Result Http.Error String)
  | LinkClicked Browser.UrlRequest
  | UrlChanged Url.Url