port module Pages.Bookmarks exposing (Model, Msg, init, update, view)

import Bookmark exposing (Bookmark)
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
                            [ text (interpolate "Bookmarks ({0})" [ String.fromInt (List.length bookmarks) ])
                            , button [ class "siimple-btn siimple-btn--teal siimple--float-right" ] [ text "Add a new bookmark" ]
                            ]
                        ]
                    , div [ class "siimbple-grid-row" ] (viewBookmarks bookmarks)
                    ]
            )
        |> Maybe.withDefault (div [] [ text "loading..." ])


viewBookmarks : List Bookmark -> List (Html Msg)
viewBookmarks bookmarks =
    bookmarks
        |> List.map
            (\bookmark ->
                div [ class "siimple-grid-col siimple-grid-col--3 siimple-grid-col--lg-4 siimple-grid-col--md-6 siimple-grid-col--xs-12" ]
                    [ a [ class "bookmark-item siimple-card", href bookmark.url ]
                        [ div [ class "siimple-card-body" ]
                            [ div [ class "siimple-card-title" ] [ text bookmark.title ]
                            , div [ class "siimple-card-subtitle" ] [ text bookmark.url ]
                            , text bookmark.description
                            ]
                        ]
                    ]
            )



------ Port ------


port logsOut : () -> Cmd msg
