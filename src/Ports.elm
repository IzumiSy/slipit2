port module Ports exposing (..)

import Models exposing (..)

port startLoggingIn : LoginForm -> Cmd msg

port logInSucceeded : (User -> msg) -> Sub msg

port logInFailed : (LoginError -> msg) -> Sub msg