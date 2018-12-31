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
  | SucceedsInLoggingIn User
  | FailsLoggingIn LoginError
  | SignsOut
  | SignedOut ()
  | UpdateNewBookmarkUrl String
  | UpdateNewBookmarkTitle String
  | UpdateNewBookmarkDescription String
  | CreatesNewbookmark
  | StartFetchingWebPageTitle
  | WebPageTitleFetched (Result Http.Error (List ScrapingResult))
  | LinkClicked Browser.UrlRequest
  | UrlChanged Url.Url