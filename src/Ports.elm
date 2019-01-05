port module Ports exposing (..)

import Models exposing (..)


-- Outgoings

port startLoggingIn : LoginForm -> Cmd msg

port signsOut : () -> Cmd msg

port createsNewBookmark : (Bookmark, User) -> Cmd msg

port fetchesBookmarks : User -> Cmd msg

-- Incomings

port creatingNewBookmarkSucceeded : (Bookmark -> msg) -> Sub msg

port creatingNewBookmarkFailed : (BookmarkCreatingError -> msg) -> Sub msg

port fetchingBookmarksSucceeded : (List Bookmark -> msg) -> Sub msg

port fetchingBookmarksFailed : (BookmarksFetchingError -> msg) -> Sub msg 

port logInSucceeded : (InitialUserData -> msg) -> Sub msg

port logInFailed : (LoginError -> msg) -> Sub msg

port signedOut : (() -> msg) -> Sub msg