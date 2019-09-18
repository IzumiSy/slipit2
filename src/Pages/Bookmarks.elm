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
import Bookmark.Description as Description exposing (Description)
import Bookmark.Title as Title exposing (Title)
import Bookmarks exposing (Bookmarks)
import Bookmarks.FB.Bookmark as FBBookmark
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Pages.Layout as Layout
import Session exposing (Session)
import String.Interpolate exposing (interpolate)
import Url



------ Model ------


type alias Model =
    Model.Modelable {}



------ Msg ------


type Msg
    = Noop
    | GotAppHeaderMsg AppHeader.Msg
    | FetchedAllBookmarks (Result Decode.Error (List Bookmark))



------ Update ------


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )

        GotAppHeaderMsg pageMsg ->
            AppHeader.update pageMsg model GotAppHeaderMsg

        FetchedAllBookmarks result ->
            case result of
                Err _ ->
                    ( model, Cmd.none )

                Ok bookmarks ->
                    ( { model | session = Session.mapBookmarks (Bookmarks.new bookmarks) model.session }
                    , Cmd.none
                    )



------ Init ------


init : Model.Flag -> Session -> ( Model, Cmd msg )
init flag session =
    ( { flag = flag
      , session = session
      }
    , fetchAllBookmarks ()
    )



------ View ------


view : Model -> Layout.View Msg
view model =
    Layout.new
        { title = "Bookmarks"
        , body =
            [ model.session
                |> Session.toUserData
                |> Maybe.map
                    (\{ bookmarks, currentUser } ->
                        let
                            bookmarkCount =
                                String.fromInt (bookmarks |> Bookmarks.size)
                        in
                        div []
                            [ div
                                [ class "siimple-grid-row" ]
                                [ div
                                    [ class "siimple-grid-col siimple-grid-col--12" ]
                                    [ div
                                        [ class "siimple--clearfix" ]
                                        [ div
                                            [ class "siimple--float-left" ]
                                            [ h2 [] [ text (interpolate "Bookmarks ({0})" [ bookmarkCount ]) ]
                                            ]
                                        , div
                                            [ class "siimple--float-right" ]
                                            [ a
                                                [ class "siimple-btn siimple-btn--teal siimple--float-right", href "new_bookmark" ]
                                                [ text "Add a new bookmark" ]
                                            ]
                                        ]
                                    ]
                                ]
                            , div
                                [ class "siimple-grid-row" ]
                                (bookmarks |> Bookmarks.map (Bookmark.fold viewBookmarkCard (always (div [] []))))
                            ]
                    )
                |> Maybe.withDefault (div [] [ text "loading..." ])
            ]
        }


type alias Bookmarkable a =
    { a
        | url : Url.Url
        , title : Title
        , description : Description
    }


viewBookmarkCard : Bookmarkable a -> Html msg
viewBookmarkCard { url, title, description } =
    div [ class "siimple-grid-col siimple-grid-col--3 siimple-grid-col--lg-4 siimple-grid-col--md-6 siimple-grid-col--xs-12" ]
        [ a [ class "bookmark-item siimple-card", url |> Url.toString |> href ]
            [ div [ class "siimple-card-body" ]
                [ div [ class "siimple-card-title" ] [ title |> Title.unwrap |> text ]
                , div [ class "siimple-card-subtitle" ] [ url |> Url.toString |> text ]
                , description |> Description.unwrap |> text
                ]
            ]
        ]



------ Subscriptions ------


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ allBookmarksFetched (FetchedAllBookmarks << Decode.decodeValue (Decode.list Bookmark.decoder)) ]



------ Port ------


port fetchAllBookmarks : () -> Cmd msg


port allBookmarksFetched : (Decode.Value -> msg) -> Sub msg
