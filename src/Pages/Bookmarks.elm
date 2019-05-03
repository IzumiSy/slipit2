port module Pages.Bookmarks exposing (Model, Msg, init, update, view)

import Bookmark exposing (Bookmark)
import Bookmark.Description as Description
import Bookmark.Title as Title
import Bookmark.Url as Url
import Bookmarks exposing (Bookmarks)
import Flag exposing (Flag)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Session exposing (Session)
import String.Interpolate exposing (interpolate)



------ Model ------


type alias Model =
    { flag : Flag
    , session : Session
    }



------ Msg ------


type Msg
    = LogsOut



------ Update ------


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LogsOut ->
            ( model, logsOut () )



------ Init ------


init : Flag -> Session -> Model
init flag session =
    { flag = flag
    , session = session
    }



------ View ------


view : Model -> Html Msg
view model =
    model.session
        |> Session.toUserData
        |> Maybe.map
            (\{ bookmarks, currentUser } ->
                div []
                    [ div []
                        [ div [ class "siimple-grid-row" ]
                            [ div [] [ text (String.append "Current user: " currentUser.email) ]
                            , div [] [ button [ onClick LogsOut ] [ text "logs out" ] ]
                            ]
                        ]
                    , div [ class "siimple-gird-row" ]
                        [ h2 []
                            [ text (interpolate "Bookmarks ({0})" [ String.fromInt (bookmarks |> Bookmarks.size) ])
                            , a [ class "siimple-btn siimple-btn--teal siimple--float-right", href "new_bookmark" ] [ text "Add a new bookmark" ]
                            ]
                        ]
                    , div [ class "siimbple-grid-row" ]
                        (bookmarks
                            |> Bookmarks.map
                                (\bookmark ->
                                    div [ class "siimple-grid-col siimple-grid-col--3 siimple-grid-col--lg-4 siimple-grid-col--md-6 siimple-grid-col--xs-12" ]
                                        [ a [ class "bookmark-item siimple-card", bookmark |> Bookmark.toUrl |> Url.unwrap |> href ]
                                            [ div [ class "siimple-card-body" ]
                                                [ div [ class "siimple-card-title" ] [ bookmark |> Bookmark.toTitle |> Title.unwrap |> text ]
                                                , div [ class "siimple-card-subtitle" ] [ bookmark |> Bookmark.toUrl |> Url.unwrap |> text ]
                                                , bookmark |> Bookmark.toDescription |> Description.unwrap |> text
                                                ]
                                            ]
                                        ]
                                )
                        )
                    ]
            )
        |> Maybe.withDefault (div [] [ text "loading..." ])



------ Port ------


port logsOut : () -> Cmd msg
