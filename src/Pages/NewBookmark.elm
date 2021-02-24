port module Pages.NewBookmark exposing
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import App.Model as Model
import Bookmark exposing (Bookmark)
import Bookmarks
import Flag
import Flag.Function as Function
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Json.Encode as Encode
import Pages
import Pages.Layout as Layout
import Pages.NewBookmark.Description as Description exposing (Description)
import Pages.NewBookmark.Title as Title exposing (Title)
import Pages.NewBookmark.Url as Url exposing (Url)
import Route
import Session exposing (Session)
import String.Interpolate exposing (interpolate)
import Task
import Toasts
import Typed
import User as User



-- model


type alias Model =
    Model.Modelable
        { url : Url
        , title : Title
        , description : Description
        }


init : Url -> Title -> Description -> Flag.Flag -> Session -> ( Model, Cmd Msg )
init url title description flag session =
    ( { flag = flag
      , session = session
      , url = url
      , title = title
      , description = description
      }
    , Cmd.none
    )



-- update


type Msg
    = SetUrl Url
    | UrlBlurred
    | SetTitle Title
    | TitleBlurred
    | SetDescription Description
    | DescriptionBlurred
    | CreatesNewbookmark
    | CreatingNewBookmarkSucceeded (Result Decode.Error Bookmark)
    | CreatingNewBookmarkFailed (Result Decode.Error String)
    | PrefetchesPage
    | PagePrefetched (Result Function.Error Function.Result_)


update : Msg -> Model -> ( Model, Cmd Msg, Session.Ops )
update msg model =
    case msg of
        SetUrl value ->
            ( { model | url = value }, Cmd.none, Session.NoOp )

        UrlBlurred ->
            ( { model | url = Url.blur model.url }, Cmd.none, Session.NoOp )

        SetTitle value ->
            ( { model | title = value }, Cmd.none, Session.NoOp )

        TitleBlurred ->
            ( { model | title = Title.blur model.title }, Cmd.none, Session.NoOp )

        SetDescription value ->
            ( { model | description = value }, Cmd.none, Session.NoOp )

        DescriptionBlurred ->
            ( { model | description = Description.blur model.description }, Cmd.none, Session.NoOp )

        CreatesNewbookmark ->
            case Session.toUserData model.session of
                Just { currentUser } ->
                    ( model
                    , model
                        |> toValidatedModel
                        |> Maybe.map (newBookmarkPayload currentUser)
                        |> Maybe.map createsNewBookmark
                        |> Maybe.withDefault Cmd.none
                    , Session.NoOp
                    )

                _ ->
                    ( model, Cmd.none, Session.NoOp )

        CreatingNewBookmarkSucceeded result ->
            ( model
            , Route.replaceUrl (Session.toNavKey model.session) Route.Bookmarks
            , result
                |> Result.toMaybe
                |> Maybe.map (Session.AddToast << Toasts.Added)
                |> Maybe.withDefault Session.NoOp
            )

        CreatingNewBookmarkFailed _ ->
            ( model, Cmd.none, Session.NoOp )

        PrefetchesPage ->
            ( model
            , model.flag.function
                |> Function.run model.url
                |> Task.attempt PagePrefetched
            , Session.NoOp
            )

        PagePrefetched result ->
            case result of
                Ok { title, description } ->
                    ( { model | title = title, description = description }, Cmd.none, Session.NoOp )

                Err err ->
                    ( model, Cmd.none, Session.UnknownError <| Function.errorToString err )



-- view


view : Model -> Layout.View Msg
view ({ url, title, description, session } as model) =
    let
        isSubmittable =
            model
                |> toValidatedModel
                |> Maybe.map (\_ -> True)
                |> Maybe.withDefault False
    in
    Layout.new
        { title = "New Bookmark"
        , body =
            [ div [ class "main-container siimple-grid" ]
                [ Html.form
                    [ Pages.onSubmitWithPrevented CreatesNewbookmark ]
                    [ div [ class "siimple-form" ]
                        [ div [ class "siimple-form-title" ] [ text "New bookmark" ]
                        , session
                            |> Session.toUserData
                            |> Maybe.map .bookmarks
                            |> Maybe.andThen (Bookmarks.find url)
                            |> Maybe.map
                                (\bookmark ->
                                    div [ class "siimple-alert siimple-alert--warning" ]
                                        [ text <|
                                            interpolate
                                                "\"{0}\" is already bookmarked!"
                                                [ Typed.value <| Bookmark.title bookmark ]
                                        ]
                                )
                            |> Maybe.withDefault (div [] [])
                        , div [ class "siimple-form-field" ]
                            [ div [ class "siimple-form-field-label" ] [ text "url" ]
                            , Url.view SetUrl UrlBlurred url
                            ]
                        , div [ class "siimple-form-field" ]
                            [ div [ class "siimple-form-field-label" ] [ text "title" ]
                            , Title.view SetTitle TitleBlurred title
                            ]
                        , div [ class "siimple-form-field" ]
                            [ div [ class "siimple-form-field-label" ] [ text "description" ]
                            , Description.view SetDescription DescriptionBlurred description
                            ]
                        , div [ class "siimple-form-field" ]
                            [ button
                                [ type_ "button"
                                , onClick PrefetchesPage
                                , disabled <| not isSubmittable
                                , class "siimple-btn siimple--mr-2 siimple-grid-col--2"
                                ]
                                [ text "fetch" ]
                            , button
                                [ type_ "submit"
                                , disabled <| not isSubmittable
                                , class "siimple-btn siimple-btn--blue siimple-grid-col--2"
                                ]
                                [ text "create" ]
                            ]
                        ]
                    ]
                ]
            ]
        }



-- subscription


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ creatingNewBookmarkSucceeded (CreatingNewBookmarkSucceeded << Decode.decodeValue Bookmark.decoder)
        , creatingNewBookmarkFailed (CreatingNewBookmarkFailed << Decode.decodeValue Decode.string)
        ]



-- port


{-| バリデーション済みであることを表現するデータ型
-}
type Validated
    = Validated Model


toValidatedModel : Model -> Maybe Validated
toValidatedModel model =
    model
        |> (Validated >> Just)
        |> Maybe.andThen (\_ -> Title.error <| Title.blur model.title)
        |> Maybe.andThen (\_ -> Description.error <| Description.blur model.description)
        |> Maybe.andThen (\_ -> Url.error <| Url.blur model.url)
        |> Maybe.andThen (\_ -> Nothing)


newBookmarkPayload : User.User -> Validated -> Encode.Value
newBookmarkPayload user (Validated { url, title, description }) =
    Encode.object
        [ ( "bookmark"
          , Encode.object
                [ ( "title", Title.encode title )
                , ( "description", Description.encode description )
                , ( "url", Url.encode url )
                ]
          )
        , ( "uid", Typed.encodeStrict User.UidType Encode.string (User.uid user) )
        ]


port createsNewBookmark : Encode.Value -> Cmd msg


port creatingNewBookmarkSucceeded : (Decode.Value -> msg) -> Sub msg


port creatingNewBookmarkFailed : (Decode.Value -> msg) -> Sub msg
