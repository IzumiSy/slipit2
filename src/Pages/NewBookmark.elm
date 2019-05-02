module Pages.NewBookmark exposing (Model, Msg, init, view)

import Bookmark exposing (Bookmark)
import Flag exposing (Flag)
import Html exposing (..)
import Html.Attributes exposing (..)
import Session exposing (Session)



------ Model ------
{-
   type alias UrlFetcherResult =
       { title : String
       , description : String
       }


   type UrlFetchingStatus
       = UrlNotFetched
       | UrlFetching
       | UrlFetched (Result { message : String } UrlFetcherResult)


   type UrlFetchingError
       = UrlFetchingError String


   unwrapUrlFetchingError : UrlFetchingError -> String
   unwrapUrlFetchingError (UrlFetchingError msg) =
       msg


   type alias NewBookmarkForm =
       { url : String
       , title : String
       , description : String
       }


   emptyBookmark =
       { url = "", title = "", description = "" }


   setUrl v bookmark =
       { bookmark | url = v }


   setTitle v bookmark =
       { bookmark | title = v }


   setDescription v bookmark =
       { bookmark | description = v }



   type NewBookmarkCreatingStatus
       = NewBookmarkNotCreated
       | NewBookmarkCreating
       | NewBookmarkCreated (Result BookmarkCreatingError Bookmark)


   type alias BookmarkCreatingError =
       { message : String
       }
-}


type alias Model =
    { flag : Flag
    , session : Session
    }



------ Msg ------


type Msg
    = Noop



------ Init ------


init : Flag -> Session -> Model
init flag session =
    { flag = flag
    , session = session
    }



------ View ------


view : Model -> Html msg
view model =
    div [] [ text "new bookmark" ]



{-
   homeView : UserData -> Html Msg
   homeView userData =
       let
           titleFetchingErrorM =
               case userData.urlFetchingStatus of
                   UrlFetched fetchedResult ->
                       case fetchedResult of
                           Err err ->
                               Just (String.append "Error: " (unwrapUrlFetchingError err))

                           _ ->
                               Nothing

                   _ ->
                       Nothing

           fetchButtonText =
               case userData.urlFetchingStatus of
                   UrlFetching ->
                       "Fetching..."

                   _ ->
                       "Fetch"

           currentUser =
               userData.currentUser
       in
       div [ class "main-container siimple-grid" ]
           [ div [ class "bookmark-list siimple-gird-row" ] (renderBookmarkItems userData.bookmarks)
           , div [ class "siimple-grid-row" ]
               [ p [] [ text "New bookmark" ]
               , Html.form [ onSubmitWithPrevented CreatesNewbookmark ]
                   [ div []
                       [ label []
                           [ text "url:"
                           , input [ placeholder "Url to bookmark", required True, value userData.newBookmark.url, onInput UpdateNewBookmarkUrl ] []
                           ]
                       ]
                   , div []
                       [ label []
                           [ text "title:"
                           , input [ placeholder "Title", value userData.newBookmark.title, onInput UpdateNewBookmarkTitle ] []
                           ]
                       ]
                   , div []
                       [ label []
                           [ text "description:"
                           , input [ placeholder "Description", value userData.newBookmark.description, onInput UpdateNewBookmarkDescription ] []
                           ]
                       ]
                   , div []
                       [ div []
                           [ button [ type_ "button", onClick StartFetchingWebPageTitle ] [ text fetchButtonText ]
                           ]
                       , div [] [ button [ type_ "submit" ] [ text "create" ] ]
                       ]
                   ]
               ]

           -- div [] [text (interpolate "Title: {0}" [fetchedTitle])]
           ]
-}
