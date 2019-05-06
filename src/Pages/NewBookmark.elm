port module Pages.NewBookmark exposing (Model, Msg, init, view)

import Bookmark exposing (Bookmark)
import Bookmark.Description as Description exposing (Description)
import Bookmark.Title as Title exposing (Title)
import Flag exposing (Flag)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Pages
import Session exposing (Session)
import Url



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
    , url : Maybe Url.Url
    , title : Title
    , description : Description
    }



------ Msg ------


type Msg
    = SetUrl String
    | SetTitle String
    | SetDescription String
    | CreatesNewbookmark
    | CreatingNewBookmarkSucceeded Bookmark
    | CreatingNewBookmarkFailed String
    | StartFetchingPageInfo
    | PageInfoFetched (Result Http.Error PageInfo)


------ Update ------
{-
   update : Msg -> Model -> ( Model, Cmd Msg )
   update msg model =
       let
           fetchUserData =
               authenticater model

           updateUserData =
               userDataUpdater model

           updateLoginForm =
               loginFormUpdater model

           navigateTo =
               Route.pushUrl model.navKey
       in
       case msg of
           UpdateNewBookmarkUrl url ->
               updateUserData
                   (\userData ->
                       let
                           updated =
                               userData.newBookmark |> setUrl url
                       in
                       ( { userData | newBookmark = updated }, Cmd.none )
                   )

           UpdateNewBookmarkTitle title ->
               updateUserData
                   (\userData ->
                       let
                           updated =
                               userData.newBookmark |> setTitle title
                       in
                       ( { userData | newBookmark = updated }, Cmd.none )
                   )

           UpdateNewBookmarkDescription desc ->
               updateUserData
                   (\userData ->
                       let
                           updated =
                               userData.newBookmark |> setDescription desc
                       in
                       ( { userData | newBookmark = updated }, Cmd.none )
                   )

           CreatesNewbookmark ->
               updateUserData
                   (\userData ->
                       ( { userData | newBookmarkCreatingStatus = NewBookmarkCreating }, createsNewBookmark ( userData.newBookmark, userData.currentUser ) )
                   )

           CreatingNewBookmarkSucceeded createdBookmark ->
               updateUserData
                   (\userData ->
                       ( { userData | newBookmarkCreatingStatus = NewBookmarkCreated (Ok createdBookmark) }, fetchesBookmarks userData.currentUser )
                   )

           CreatingNewBookmarkFailed err ->
               ( model, Cmd.none )

           -- TODO: あとでつくる
           StartFetchingWebPageTitle ->
               updateUserData
                   (\userData ->
                       ( { userData | urlFetchingStatus = UrlFetching }, fetchUrl model.appConfig.functionUrl userData.newBookmark.url )
                   )

           NewUrlFetched result ->
               updateUserData
                   (\userData ->
                       let
                           mappedResult =
                               Result.mapError
                                   (\err ->
                                       case err of
                                           Http.BadBody errMsg ->
                                               UrlFetchingError errMsg

                                           _ ->
                                               UrlFetchingError "Unexpected error"
                                   )
                                   result

                           ( title, description ) =
                               case mappedResult of
                                   Ok r ->
                                       ( r.title, r.description )

                                   _ ->
                                       ( userData.newBookmark.title, userData.newBookmark.description )

                           updated =
                               userData.newBookmark |> setTitle title |> setDescription description
                       in
                       ( { userData | newBookmark = updated, urlFetchingStatus = UrlFetched mappedResult }, Cmd.none )
                   )
-}


------ HTTP ------
{-
   fetchUrl : String -> String -> Cmd Msg
   fetchUrl functionUrl targetUrl =
       Http.get
           { url = interpolate "{0}?url={1}" [ functionUrl, targetUrl ]
           , expect = Http.expectJson NewUrlFetched urlFetcherDecoder
           }


   urlFetcherDecoder : Decode.Decoder UrlFetcherResult
   urlFetcherDecoder =
       Decode.map2 UrlFetcherResult
           (field "title" string)
           (field "description" string)
-}

------ Init ------


init : Maybe Url.Url -> Title -> Description -> Flag -> Session -> Model
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
                            , url |> Maybe.map Url.toString |> Maybe.withDefault "" |> value
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


------ Port ------
{-
   port createsNewBookmark : ( Bookmark, User ) -> Cmd msg


   port creatingNewBookmarkSucceeded : (Bookmark -> msg) -> Sub msg


   port creatingNewBookmarkFailed : (BookmarkCreatingError -> msg) -> Sub msg
-}