module Views exposing (homeView, loadingView, loginView, onSubmitWithPrevented, renderBookmarkItems, view, viewLink)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Models exposing (..)
import Msgs exposing (..)
import Route
import String.Interpolate exposing (interpolate)



-- View
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
           [ div [ class "siimple-grid-row" ]
               [ div [] [ text (String.append "Current user: " currentUser.email) ]
               , div [] [ button [ onClick SignsOut ] [ text "sign out" ] ]
               ]
           , div [ class "siimple-gird-row" ]
               [ h2 []
                   [ text (interpolate "Bookmarks ({0})" [ String.fromInt (List.length userData.bookmarks) ])
                   , button [ class "siimple-btn siimple-btn--teal siimple--float-right" ] [ text "Add a new bookmark" ]
                   ]
               ]
           , div [ class "bookmark-list siimple-gird-row" ] (renderBookmarkItems userData.bookmarks)
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


   renderBookmarkItems : List Bookmark -> List (Html Msg)
   renderBookmarkItems bookmarks =
       List.map
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
           bookmarks


   loadingView : Html Msg
   loadingView =
       div [ class "siimple-grid" ]
           [ div [ class "siimple-grid-row" ]
               [ div [] [ text "Loading..." ]
               ]
           ]
-}
