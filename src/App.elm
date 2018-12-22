module App exposing (Model, Msg, update, view, subscriptions)

import Browser exposing (element)
import Html exposing (..)


type alias Bookmark =
  {
    url: String,
    title: String,
    description: String
  }


type alias Model =
  {
    bookmarks: List Bookmark
  }


type Msg
  = Msg1 | Msg2


init : () -> (Model, Cmd Msg)
init _ =
  (
    {
      bookmarks = []
    },
    Cmd.none
  )


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Msg1 ->
            (model, Cmd.none)
        Msg2 ->
            (model, Cmd.none)


view : Model -> Html Msg
view model =
    div []
        [ text "New Html Program" ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main =
    element {
      init = init,
      view = view,
      update = update,
      subscriptions = subscriptions
    }