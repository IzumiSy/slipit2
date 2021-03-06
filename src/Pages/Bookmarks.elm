port module Pages.Bookmarks exposing
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import App.Model as Model
import Bookmark exposing (Bookmark)
import Bookmarks exposing (Bookmarks)
import Flag
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Pages.Layout as Layout
import Session exposing (Session)
import String.Interpolate exposing (interpolate)
import Typed



-- model


type alias Model =
    Model.Modelable {}


init : Flag.Flag -> Session -> ( Model, Cmd msg )
init flag session =
    ( { flag = flag
      , session =
            flag.cachedBookmarks
                |> Maybe.map (\bookmarks -> Session.mapBookmarks bookmarks session)
                |> Maybe.withDefault session
      }
    , fetchAllBookmarks ()
    )



-- update


type Msg
    = Noop
    | FetchedAllBookmarks (Result Decode.Error Bookmarks)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )

        FetchedAllBookmarks result ->
            result
                |> Result.map
                    (\bookmarks ->
                        ( { model | session = Session.mapBookmarks bookmarks model.session }
                        , Bookmarks.persistToCache bookmarks
                        )
                    )
                |> Result.withDefault ( model, Cmd.none )



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
                                    |> Bookmarks.toList
                                    |> List.map viewBookmarkCard
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
                [ class "siimple--clearfix header-border" ]
                [ div
                    [ class "siimple--float-left" ]
                    [ div
                        [ class "siimple-h3 bookmarks-header" ]
                        [ text (interpolate "Bookmarks ({0})" [ bookmarkCount ]) ]
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
        [ a [ class "bookmark-item siimple-card", href <| Typed.value <| Bookmark.url bookmark ]
            [ div [ class "bookmark-item-body siimple-card-body" ]
                [ div [ class "siimple-card-title" ] [ text <| Typed.value <| Bookmark.title bookmark ]
                , div [ class "siimple-card-subtitle" ] [ text <| Typed.value <| Bookmark.url bookmark ]
                , text <| Typed.value <| Bookmark.description bookmark
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
