port module Pages.Bookmarks exposing
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
import Bookmark.Description as Description
import Bookmark.Title as Title
import Bookmark.Url as Url
import Bookmarks exposing (Bookmarks)
import Flag
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Pages.Layout as Layout
import Session exposing (Session)
import String.Interpolate exposing (interpolate)



-- model


type alias Model =
    Model.Modelable {}


init : Flag.Flag -> Session -> ( Model, Cmd msg )
init flag session =
    ( { flag = flag
      , session = session
      }
    , fetchAllBookmarks ()
    )



-- update


type Msg
    = Noop
    | GotAppHeaderMsg AppHeader.Msg
    | FetchedAllBookmarks (Result Decode.Error Bookmarks)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )

        GotAppHeaderMsg pageMsg ->
            AppHeader.update pageMsg model

        FetchedAllBookmarks result ->
            ( result
                |> Result.map
                    (\bookmarks ->
                        { model | session = Session.mapBookmarks bookmarks model.session }
                    )
                |> Result.withDefault model
            , Cmd.none
            )



-- view


view : Model -> Layout.View Msg
view model =
    Layout.new
        { title = "Bookmarks"
        , body =
            [ model.session
                |> Session.toUserData
                |> Maybe.map
                    (\{ bookmarks } ->
                        div []
                            [ header bookmarks
                            , div
                                [ class "siimple-grid-row" ]
                                (bookmarks
                                    |> Bookmarks.toListOrdered
                                    |> Bookmarks.map viewBookmarkCard
                                )
                            ]
                    )
                |> Maybe.withDefault (div [] [ text "loading..." ])
            ]
        }


header : Bookmarks -> Html Msg
header bookmarks =
    let
        bookmarkCount =
            String.fromInt (bookmarks |> Bookmarks.size)
    in
    div
        [ class "siimple-grid-row" ]
        [ div
            [ class "siimple-grid-col siimple-grid-col--12" ]
            [ div
                [ class "siimple--clearfix" ]
                [ div
                    [ class "siimple--float-left" ]
                    [ div [ class "siimple-h3" ] [ text (interpolate "Bookmarks ({0})" [ bookmarkCount ]) ]
                    ]
                , div
                    [ class "siimple--float-right" ]
                    [ a
                        [ class "siimple-btn siimple-btn--teal siimple--float-right"
                        , href "new_bookmark"
                        ]
                        [ text "Add a new bookmark" ]
                    ]
                ]
            ]
        ]


viewBookmarkCard : Bookmark -> Html msg
viewBookmarkCard bookmark =
    div [ class "siimple-grid-col siimple-grid-col--3 siimple-grid-col--lg-4 siimple-grid-col--md-6 siimple-grid-col--xs-12" ]
        [ a [ class "bookmark-item siimple-card", Url.href <| Bookmark.url bookmark ]
            [ div [ class "bookmark-item-body siimple-card-body" ]
                [ div [ class "siimple-card-title" ] [ Title.text <| Bookmark.title bookmark ]
                , div [ class "siimple-card-subtitle" ] [ Url.text <| Bookmark.url bookmark ]
                , Description.text <| Bookmark.description bookmark
                ]
            ]
        ]



-- subscription


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ allBookmarksFetched (FetchedAllBookmarks << Decode.decodeValue Bookmarks.decode) ]



-- port


port fetchAllBookmarks : () -> Cmd msg


port allBookmarksFetched : (Decode.Value -> msg) -> Sub msg
