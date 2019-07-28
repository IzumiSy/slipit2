port module Pages.SignIn exposing (Model, Msg, init, subscriptions, update, view)

import App.Model as Model
import App.View as View
import Bookmark exposing (Bookmark)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Json.Decode as Decode
import Pages
import Pages.FB.AuthError as FBAuthError
import Pages.FB.User as FBUser
import Pages.Form.Email as Email exposing (Email)
import Pages.Form.Password as Password exposing (Password)
import Route
import Session exposing (Session)



------ Model ------


type alias Model =
    Model.Modelable
        { email : Email
        , password : Password
        , error : FBAuthError.Error
        }



------ Msg ------


type Msg
    = SetEmail String
    | SetPassword String
    | StartsLoggingIn
    | LoggingInFailed FBAuthError.Payload



------ Update ------


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetPassword value ->
            ( { model | password = Password.new value }, Cmd.none )

        SetEmail value ->
            ( { model | email = Email.new value }, Cmd.none )

        StartsLoggingIn ->
            ( { model | session = model.session |> Session.mapAsLoggingIn }
            , startsLoggingIn
                { password = model.password |> Password.unwrap
                , email = model.email |> Email.unwrap
                }
            )

        LoggingInFailed payload ->
            ( { model
                | error = FBAuthError.new payload
                , session = model.session |> Session.mapAsNotLoggedIn
              }
            , Cmd.none
            )



------ Init ------


init : Model.Flag -> Session -> Model
init flag session =
    { email = Email.empty
    , password = Password.empty
    , error = FBAuthError.init
    , flag = flag
    , session = session
    }



------ View ------


view : Model -> View.AppView Msg
view { flag, email, password, error, session } =
    View.new
        { title = "Sign In"
        , body =
            [ div [ class "siimple-grid" ]
                [ div [ class "siimple-grid-row" ]
                    [ div [ class "siimple-grid-col siimple-grid-col--4 siimple-grid-col--xl-3 siimple-grid-col--md-1 siimple-grid-col--sm-12-hide" ] []
                    , div [ class "siimple-grid-col siimple-grid-col--4 siimple-grid-col--xl-6 siimple-grid-col--md-10 siimple-grid-col--sm-12" ]
                        [ div [ class "login" ]
                            [ h2 [ class "login-header" ]
                                [ img [ class "image", src flag.logoImagePath ] []
                                , div [ class "content centered-xs" ]
                                    [ text "Log in to Slip.it"
                                    , h5 [] [ text "Your online bookmarks never be social." ]
                                    ]
                                ]
                            , Html.form [ Pages.onSubmitWithPrevented StartsLoggingIn, class "siimple-form login-fields" ]
                                [ error
                                    |> FBAuthError.toMessage
                                    |> Maybe.map (\message -> div [ class "siimple-alert siimple-alert--warning" ] [ text message ])
                                    |> Maybe.withDefault (div [] [])
                                , div [ class "siimple-form-field" ]
                                    [ div [ class "siimple-form-field-label" ] [ text "E-mail" ]
                                    , input
                                        [ type_ "email"
                                        , class "siimple-input siimple-input--fluid"
                                        , placeholder "Your email"
                                        , required True
                                        , email |> Email.unwrap |> value
                                        , onInput SetEmail
                                        , session |> Session.isLoggingIn |> disabled
                                        ]
                                        []
                                    ]
                                , div [ class "siimple-form-field" ]
                                    [ div [ class "siimple-form-field-label" ] [ text "Password" ]
                                    , input
                                        [ type_ "password"
                                        , class "siimple-input siimple-input--fluid"
                                        , placeholder "Your password"
                                        , required True
                                        , password |> Password.unwrap |> value
                                        , onInput SetPassword
                                        , session |> Session.isLoggingIn |> disabled
                                        ]
                                        []
                                    ]
                                , div [ class "siimple-form-field" ]
                                    [ button
                                        [ class "siimple-btn siimple-btn--teal siimple-btn--fluid"
                                        , session |> Session.isLoggingIn |> disabled
                                        ]
                                        [ text
                                            (if session |> Session.isLoggingIn then
                                                "Logging in..."

                                             else
                                                "Login"
                                            )
                                        ]
                                    ]
                                ]
                            , div [ class "siimple-grid-row siimple--text-center" ]
                                [ div [ class "signup-guidance" ]
                                    [ text "New to Slip.it?"
                                    , Pages.viewLink "sign_up" "Create a new account"
                                    ]
                                , div []
                                    [ Pages.viewLink "reset_password" "Forgot your own password?"
                                    ]
                                , div []
                                    [ h5 [] [ text "© 2019 IzumiSy." ]
                                    ]
                                ]
                            ]
                        ]
                    , div [ class "siimple-grid-col siimple-grid-col--4 siimple-grid-col--xl-3 siimple-grid-col--md-1 siimple-grid-col--sm-12-hide" ] []
                    ]
                ]
            ]
        }



------ Subscriptions ------
-- ログイン成功に関してはページをまたいでハンドリングする必要があるためApp.elm側でサブスクライブしている
-- 一方でログイン時のエラーはログイン画面でだけ必要なのでこちらにだけあればよい


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ loggingInFailed LoggingInFailed
        ]



------ Port ------


type alias LoginPayload =
    { email : String, password : String }


port startsLoggingIn : LoginPayload -> Cmd msg


port loggingInFailed : (FBAuthError.Payload -> msg) -> Sub msg
