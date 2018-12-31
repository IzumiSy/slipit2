port module Ports exposing (..)

import Models exposing (..)


-- Outgoings

port startLoggingIn : LoginForm -> Cmd msg

port signsOut : () -> Cmd msg

port createsNewBookmark : Bookmark -> Cmd msg

-- Incomings

port creatingNewBookmarkSucceeded : (Bookmark -> msg) -> Sub msg

port creatinNewBookmarkFailed : (BookmarkError -> msg) -> Sub msg

port logInSucceeded : (User -> msg) -> Sub msg

port logInFailed : (LoginError -> msg) -> Sub msg

port signedOut : (() -> msg) -> Sub msg