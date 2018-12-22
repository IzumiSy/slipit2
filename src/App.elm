module App exposing (Model, Msg, update, view, subscriptions, init)

import Browser exposing (element)
import Html exposing (..)


type alias Bookmark =
  {
    url: String,
    title: String,
    description: String
  }

newBookmark : (String, String, String) -> Bookmark
newBookmark (url, title, description) = { url = url, title = title, description = description }

emptyBookmark : () -> Bookmark
emptyBookmark _ = { url = "", title = "", description = "" }


type alias Model =
  {
    bookmarks: List Bookmark,
    newBookmark: Bookmark
  }

init : () -> (Model, Cmd Msg)
init _ =
  (
    {
      bookmarks = [],
      newBookmark = emptyBookmark ()
    },
    Cmd.none
  )


type Msg
  = Msg1 | Msg2


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