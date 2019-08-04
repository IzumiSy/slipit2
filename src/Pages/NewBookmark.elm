port module Pages.NewBookmark exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import App.Model as Model
import App.View as View
import Bookmark exposing (Bookmark)
import Bookmark.Description as Description exposing (Description)
import Bookmark.Title as Title exposing (Title)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Pages
import Pages.FB.User as FBUser
import Pages.NewBookmark.FB as NewBookmarkFB
import Pages.NewBookmark.PageInfo as PageInfo exposing (PageInfo)
import Pages.NewBookmark.Url as Url exposing (Url)
import Route
import Session exposing (Session)



------ Model ------


type alias Model =
    Model.Modelable { pageInfo : PageInfo }



------ Msg ------


type Msg
    = SetUrl String
    | SetTitle String
    | SetDescription String
    | CreatesNewbookmark
    | CreatingNewBookmarkSucceeded NewBookmarkFB.Bookmark
    | CreatingNewBookmarkFailed String
    | StartFetchingPageInfo
    | PageInfoFetched (Result Http.Error PageInfo)



------ Update ------


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetUrl value ->
            ( { model | pageInfo = model.pageInfo |> PageInfo.mapUrl (Url.new value) }, Cmd.none )

        SetTitle value ->
            ( { model | pageInfo = model.pageInfo |> PageInfo.mapTitle (Title.new value) }, Cmd.none )

        SetDescription value ->
            ( { model | pageInfo = model.pageInfo |> PageInfo.mapDescription (Description.new value) }, Cmd.none )

        CreatesNewbookmark ->
            case ( model.session |> Session.toUserData, model.pageInfo |> PageInfo.toUrl |> Url.unwrap ) of
                ( Just { currentUser }, Ok url ) ->
                    ( model
                    , createsNewBookmark
                        ( { url = url
                          , title = model.pageInfo |> PageInfo.toTitle |> Title.unwrap
                          , description = model.pageInfo |> PageInfo.toDescription |> Description.unwrap
                          }
                        , currentUser
                        )
                    )

                ( _, _ ) ->
                    ( model, Cmd.none )

        CreatingNewBookmarkSucceeded bookmark ->
            ( model
            , Route.replaceUrl (Session.toNavKey model.session) Route.Bookmarks
            )

        CreatingNewBookmarkFailed error ->
            ( model, Cmd.none )

        StartFetchingPageInfo ->
            ( model, model.pageInfo |> PageInfo.fetchFromRemote model.flag PageInfoFetched )

        PageInfoFetched result ->
            case result of
                Ok pageInfo ->
                    ( { model | pageInfo = pageInfo }, Cmd.none )

                Err _ ->
                    -- TODO: エラーを出す
                    ( model, Cmd.none )



------ Init ------


init : Url -> Title -> Description -> Model.Flag -> Session -> Model
init url title description flag session =
    { flag = flag
    , session = session
    , pageInfo =
        PageInfo.fromUrl url
            |> PageInfo.mapTitle title
            |> PageInfo.mapDescription description
    }



------ View ------


view : Model -> View.AppView Msg
view { pageInfo } =
    View.new
        { title = "New Bookmark"
        , body =
            [ div [ class "main-container siimple-grid" ]
                [ div [ class "siimple-grid-row" ]
                    [ p [] [ text "New bookmark" ]
                    , Html.form [ Pages.onSubmitWithPrevented CreatesNewbookmark ]
                        [ div []
                            [ label []
                                [ text "url:"
                                , input
                                    [ placeholder "Url to bookmark"
                                    , required True
                                    , pageInfo
                                        |> PageInfo.toUrl
                                        |> Url.unwrap
                                        |> (\result ->
                                                case result of
                                                    Ok v ->
                                                        v

                                                    Err v ->
                                                        v
                                           )
                                        |> value
                                    , onInput SetUrl
                                    ]
                                    []
                                ]
                            ]
                        , div []
                            [ label []
                                [ text "title:"
                                , input
                                    [ placeholder "Title"
                                    , pageInfo |> PageInfo.toTitle |> Title.unwrap |> value
                                    , onInput SetTitle
                                    ]
                                    []
                                ]
                            ]
                        , div []
                            [ label []
                                [ text "description:"
                                , input
                                    [ placeholder "Description"
                                    , pageInfo |> PageInfo.toDescription |> Description.unwrap |> value
                                    , onInput SetDescription
                                    ]
                                    []
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


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ creatingNewBookmarkSucceeded CreatingNewBookmarkSucceeded
        , creatingNewBookmarkFailed CreatingNewBookmarkFailed
        ]



------ Port ------


port createsNewBookmark : ( NewBookmarkFB.Bookmark, FBUser.User ) -> Cmd msg


port creatingNewBookmarkSucceeded : (NewBookmarkFB.Bookmark -> msg) -> Sub msg


port creatingNewBookmarkFailed : (String -> msg) -> Sub msg
