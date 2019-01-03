port module Ports exposing (..)

import Models exposing (..)


-- Outgoings

port startLoggingIn : LoginForm -> Cmd msg

port signsOut : () -> Cmd msg

port createsNewBookmark : (Bookmark, User) -> Cmd msg

-- Incomings

port creatingNewBookmarkSucceeded : (Bookmark -> msg) -> Sub msg

port creatinNewBookmarkFailed : (NewBookmarkError -> msg) -> Sub msg

port logInSucceeded : (UserData -> msg) -> Sub msg

port logInFailed : (LoginError -> msg) -> Sub msg

port signedOut : (() -> msg) -> Sub msg