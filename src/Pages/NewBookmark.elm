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
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Pages
import Pages.Layout as Layout
import Pages.NewBookmark.Description as Description exposing (Description)
import Pages.NewBookmark.Title as Title exposing (Title)
import Pages.NewBookmark.Url as Url exposing (Url)
import Route
import Session exposing (Session)
import String.Interpolate exposing (interpolate)
import Update.Extra as ExUpdate
import User as User



-- model


type alias Model =
    Model.Modelable
        { url : Url
        , title : Title
        , description : Description
        }


init : Url -> Title -> Description -> Model.Flag -> Session -> ( Model, Cmd Msg )
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
    | PagePrefetched (Result Http.Error Page)
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
            ( model, fetch PagePrefetched model )

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
view ({ url, title, description } as model) =
    Layout.new
        { title = "New Bookmark"
        , body =
            [ div [ class "main-container siimple-grid" ]
                [ div [ class "siimple-grid-row" ]
                    [ p [] [ text "New bookmark" ]
                    , Html.form [ Pages.onSubmitWithPrevented CreatesNewbookmark ]
                        [ div []
                            [ label []
                                [ text "url:"
                                , Url.view SetUrl UrlBlurred url
                                ]
                            ]
                        , div []
                            [ label []
                                [ text "title:"
                                , Title.view SetTitle TitleBlurred title
                                ]
                            ]
                        , div []
                            [ label []
                                [ text "description:"
                                , Description.view SetDescription DescriptionBlurred description
                                ]
                            ]
                        , div []
                            [ div []
                                [ button
                                    [ type_ "button"
                                    , onClick PrefetchesPage
                                    , disabled <| not <| isSubmittable model
                                    ]
                                    [ text "fetch" ]
                                ]
                            , div []
                                [ button
                                    [ type_ "submit"
                                    , disabled <| not <| isSubmittable model
                                    ]
                                    [ text "create" ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        }



-- http


type alias Page =
    { title : Title
    , description : Description
    }


fetch : (Result Http.Error Page -> msg) -> Model -> Cmd msg
fetch msg { flag, url } =
    Http.get
        { url = interpolate "{0}?url={1}" [ flag.functionUrl, Url.unwrap url ]
        , expect =
            Decode.succeed Page
                |> Pipeline.required "title" Title.decode
                |> Pipeline.required "description" Description.decode
                |> Http.expectJson msg
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
