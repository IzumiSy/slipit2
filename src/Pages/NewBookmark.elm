port module Pages.NewBookmark exposing
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import App.Header as AppHeader
import App.Model as Model
import Bookmark exposing (Bookmark)
import Bookmark.Title as BookmarkTitle
import Bookmarks
import Flag
import Flag.Function as Function
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import Pages
import Pages.Layout as Layout
import Pages.NewBookmark.Description as Description exposing (Description)
import Pages.NewBookmark.Title as Title exposing (Title)
import Pages.NewBookmark.Url as Url exposing (Url)
import Route
import Session exposing (Session)
import String.Interpolate exposing (interpolate)
import Task
import Update.Extra as ExUpdate
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


isSubmittable : Model -> Bool
isSubmittable { url, title, description } =
    Nothing
        |> Maybe.andThen (\_ -> Title.error title)
        |> Maybe.andThen (\_ -> Description.error description)
        |> Maybe.andThen (\_ -> Url.error url)
        |> Maybe.andThen (\_ -> Just False)
        |> Maybe.withDefault True



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
    | PagePrefetched (Result Http.Error Function.Result_)
    | GotAppHeaderMsg AppHeader.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetUrl value ->
            ( { model | url = value }, Cmd.none )

        UrlBlurred ->
            ( { model | url = Url.blur model.url }, Cmd.none )

        SetTitle value ->
            ( { model | title = value }, Cmd.none )

        TitleBlurred ->
            ( { model | title = Title.blur model.title }, Cmd.none )

        SetDescription value ->
            ( { model | description = value }, Cmd.none )

        DescriptionBlurred ->
            ( { model | description = Description.blur model.description }, Cmd.none )

        CreatesNewbookmark ->
            case Session.toUserData model.session of
                Just { currentUser } ->
                    ( model, Cmd.none )
                        |> ExUpdate.sequence update
                            [ UrlBlurred
                            , TitleBlurred
                            , DescriptionBlurred
                            ]
                        |> Tuple.first
                        |> (\nextModel ->
                                ( nextModel
                                , if isSubmittable nextModel then
                                    createsNewBookmark
                                        ( { url = Url.unwrap nextModel.url
                                          , title = Title.unwrap nextModel.title
                                          , description = Description.unwrap nextModel.description
                                          }
                                        , User.uid currentUser
                                        )

                                  else
                                    Cmd.none
                                )
                           )

                _ ->
                    ( model, Cmd.none )

        CreatingNewBookmarkSucceeded _ ->
            ( model
            , Route.replaceUrl (Session.toNavKey model.session) Route.Bookmarks
            )

        CreatingNewBookmarkFailed _ ->
            ( model, Cmd.none )

        PrefetchesPage ->
            ( model
            , model.flag.function
                |> Function.run model.url
                |> Task.attempt PagePrefetched
            )

        PagePrefetched result ->
            case result of
                Ok { title, description } ->
                    ( { model | title = title, description = description }, Cmd.none )

                Err _ ->
                    -- TODO: エラーを出す
                    ( model, Cmd.none )

        GotAppHeaderMsg pageMsg ->
            AppHeader.update pageMsg model



-- view


view : Model -> Layout.View Msg
view ({ url, title, description, session } as model) =
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
                                                [ BookmarkTitle.unwrap <| Bookmark.title bookmark ]
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
                                , disabled <| not <| isSubmittable model
                                , class "siimple-btn siimple--mr-2 siimple-grid-col--2"
                                ]
                                [ text "fetch" ]
                            , button
                                [ type_ "submit"
                                , disabled <| not <| isSubmittable model
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


type alias NewBookmark =
    { title : String
    , description : String
    , url : String
    }


type alias UserId =
    String


port createsNewBookmark : ( NewBookmark, UserId ) -> Cmd msg


port creatingNewBookmarkSucceeded : (Decode.Value -> msg) -> Sub msg


port creatingNewBookmarkFailed : (Decode.Value -> msg) -> Sub msg
