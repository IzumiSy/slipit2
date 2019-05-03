module Pages.NewBookmark exposing (Model, Msg, init, view)

import Bookmark exposing (Bookmark)
import Flag exposing (Flag)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Pages
import Pages.Form.Description as Description exposing (Description)
import Pages.Form.Title as Title exposing (Title)
import Pages.Form.Url as Url exposing (Url)
import Session exposing (Session)



------ Model ------
{-

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

-}


type alias PageInfo =
    { title : String
    , description : String
    }


type alias Model =
    { flag : Flag
    , session : Session
    , url : Url
    , title : Title
    , description : Description
    }



------ Msg ------
{-
   | FetchingBookmarksSucceeded (List Bookmark)
   | FetchingBookmarksFailed BookmarksFetchingError
-}


type Msg
    = SetUrl String
    | SetTitle String
    | SetDescription String
    | CreatesNewbookmark
    | CreatingNewBookmarkSucceeded Bookmark
    | CreatingNewBookmarkFailed String
    | StartFetchingPageInfo
    | PageInfoFetched (Result Http.Error PageInfo)



------ Init ------


init : Url -> Title -> Description -> Flag -> Session -> Model
init url title description flag session =
    { flag = flag
    , session = session
    , title = title
    , description = description
    , url = url
    }



------ View ------
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
       in
           -- div [] [text (interpolate "Title: {0}" [fetchedTitle])]
           ]
-}


view : Model -> Html Msg
view { url, title, description } =
    div [ class "main-container siimple-grid" ]
        [ div [ class "siimple-grid-row" ]
            [ p [] [ text "New bookmark" ]
            , Html.form [ Pages.onSubmitWithPrevented CreatesNewbookmark ]
                [ div []
                    [ label []
                        [ text "url:"
                        , input
                            [ placeholder "Url to bookmark"
                            , required True
                            , url |> Url.unwrap |> value
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
                            , title |> Title.unwrap |> value
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
                            , description |> Description.unwrap |> value
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
                            ]
                            [ text "fetch" ]
                        ]
                    , div [] [ button [ type_ "submit" ] [ text "create" ] ]
                    ]
                ]
            ]
        ]
