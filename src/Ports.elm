port module Ports exposing (..)

import Models exposing (..)

port startLoggingIn : LoginForm -> Cmd msg

port signsOut : () -> Cmd msg

port logInSucceeded : (User -> msg) -> Sub msg

port logInFailed : (LoginError -> msg) -> Sub msg

port signedOut : (() -> msg) -> Sub msg