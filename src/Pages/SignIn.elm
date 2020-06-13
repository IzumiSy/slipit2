port module Pages.SignIn exposing (Model, Msg, init, subscriptions, update, view)

import App.Model as Model
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Decode
import Pages
import Pages.Form.Email as Email exposing (Email)
import Pages.Form.Password as Password exposing (Password)
import Pages.Layout as Layout
import Pages.SignIn.FB.AuthError as FBAuthError
import Session exposing (Session)



-- model


type alias Model =
    Model.Modelable
        { email : Email
        , password : Password
        , error : FBAuthError.Error
        }


init : Model.Flag -> Session -> ( Model, Cmd Msg )
init flag session =
    ( { email = Email.empty
      , password = Password.empty
      , error = FBAuthError.init
      , flag = flag
      , session = session
      }
    , Cmd.none
    )



-- update


type Msg
    = SetEmail Email
    | SetPassword Password
    | StartsLoggingIn
    | LoggingInFailed (Result Decode.Error FBAuthError.Error)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetPassword password ->
            ( { model | password = password }, Cmd.none )

        SetEmail email ->
            ( { model | email = email }, Cmd.none )

        StartsLoggingIn ->
            ( { model | session = model.session |> Session.mapAsLoggingIn }
            , startsLoggingIn
                { password = Password.toString model.password
                , email = Email.toString model.email
                }
            )

        LoggingInFailed result ->
            case result of
                Ok fbError ->
                    ( { model
                        | error = fbError
                        , session = model.session |> Session.mapAsNotLoggedIn
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, Cmd.none )



-- view


viewEmail : Model -> Html Msg
viewEmail { email, session } =
    Email.view
        SetEmail
        [ class "siimple-input siimple-input--fluid"
        , disabled <| Session.isLoggingIn session
        ]
        email


viewPassword : Model -> Html Msg
viewPassword { password, session } =
    Password.view
        SetPassword
        [ class "siimple-input siimple-input--fluid"
        , disabled <| Session.isLoggingIn session
        ]
        password


view : Model -> Layout.View Msg
view ({ flag, error, session } as model) =
    Layout.new
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
                                    , viewEmail model
                                    ]
                                , div [ class "siimple-form-field" ]
                                    [ div [ class "siimple-form-field-label" ] [ text "Password" ]
                                    , viewPassword model
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



-- subscription
-- ログイン成功に関してはページをまたいでハンドリングする必要があるためApp.elm側でサブスクライブしている
-- 一方でログイン時のエラーはログイン画面でだけ必要なのでこちらにだけあればよい


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ loggingInFailed (LoggingInFailed << Decode.decodeValue FBAuthError.decoder)
        ]



-- port


port startsLoggingIn : { email : String, password : String } -> Cmd msg


port loggingInFailed : (Decode.Value -> msg) -> Sub msg
