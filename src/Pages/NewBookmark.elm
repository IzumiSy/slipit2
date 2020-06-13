port module Pages.NewBookmark exposing
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

-- import Bookmark.Description as Description exposing (Description)

import App.Header as AppHeader
import App.Model as Model
import Bookmark exposing (Bookmark)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import Pages
import Pages.Layout as Layout
import Pages.NewBookmark.Description as Description exposing (Description)
import Pages.NewBookmark.PageInfo as PageInfo exposing (PageInfo)
import Pages.NewBookmark.Title as Title exposing (Title)
import Pages.NewBookmark.Url as Url exposing (Url)
import Route
import Session exposing (Session)
import User as User



------ Model ------


type alias Model =
    Model.Modelable { pageInfo : PageInfo }



------ Msg ------


type Msg
    = SetUrl Url
    | SetTitle Title
    | SetDescription Description
    | CreatesNewbookmark
    | CreatingNewBookmarkSucceeded (Result Decode.Error Bookmark)
    | CreatingNewBookmarkFailed (Result Decode.Error String)
    | StartFetchingPageInfo
    | PageInfoFetched (Result Http.Error PageInfo)
    | GotAppHeaderMsg AppHeader.Msg



------ Update ------


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetUrl value ->
            ( { model | pageInfo = PageInfo.mapUrl value model.pageInfo }, Cmd.none )

        SetTitle value ->
            ( { model | pageInfo = PageInfo.mapTitle value model.pageInfo }, Cmd.none )

        SetDescription value ->
            ( { model | pageInfo = PageInfo.mapDescription value model.pageInfo }, Cmd.none )

        CreatesNewbookmark ->
            case Session.toUserData model.session of
                Just { currentUser } ->
                    ( model
                    , createsNewBookmark
                        ( { url = model.pageInfo |> PageInfo.toUrl |> Url.unwrap
                          , title = model.pageInfo |> PageInfo.toTitle |> Title.unwrap
                          , description = model.pageInfo |> PageInfo.toDescription |> Description.unwrap
                          }
                        , User.uid currentUser
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

        StartFetchingPageInfo ->
            ( model, model.pageInfo |> PageInfo.fetch model.flag PageInfoFetched )

        PageInfoFetched result ->
            case result of
                Ok pageInfo ->
                    ( { model | pageInfo = pageInfo }, Cmd.none )

                Err _ ->
                    -- TODO: エラーを出す
                    ( model, Cmd.none )

        GotAppHeaderMsg pageMsg ->
            AppHeader.update pageMsg model



------ Init ------


init : Url -> Title -> Description -> Model.Flag -> Session -> ( Model, Cmd Msg )
init url title description flag session =
    ( { flag = flag
      , session = session
      , pageInfo =
            PageInfo.fromUrl url
                |> PageInfo.mapTitle title
                |> PageInfo.mapDescription description
      }
    , Cmd.none
    )



------ View ------


view : Model -> Layout.View Msg
view { pageInfo } =
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
                                , Url.view SetUrl (PageInfo.toUrl pageInfo)
                                ]
                            ]
                        , div []
                            [ label []
                                [ text "title:"
                                , Title.view SetTitle (PageInfo.toTitle pageInfo)
                                ]
                            ]
                        , div []
                            [ label []
                                [ text "description:"
                                , Description.view SetDescription (PageInfo.toDescription pageInfo)
                                ]
                            ]
                        , div []
                            [ div []
                                [ button
                                    [ type_ "button"
                                    , onClick StartFetchingPageInfo
                                    , pageInfo |> PageInfo.toUrl |> Url.isValid |> not |> disabled
                                    ]
                                    [ text "fetch" ]
                                ]
                            , div []
                                [ button
                                    [ type_ "submit"
                                    , pageInfo |> PageInfo.toUrl |> Url.isValid |> not |> disabled
                                    ]
                                    [ text "create" ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        }



------ Subscription ------


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ creatingNewBookmarkSucceeded (CreatingNewBookmarkSucceeded << Decode.decodeValue Bookmark.decoder)
        , creatingNewBookmarkFailed (CreatingNewBookmarkFailed << Decode.decodeValue Decode.string)
        ]



------ Port ------


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
