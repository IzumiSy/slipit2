port module Pages.NewBookmark exposing (Model, Msg, init, subscriptions, view)

import Bookmark exposing (Bookmark)
import Bookmark.Description as Description exposing (Description)
import Bookmark.Title as Title exposing (Title)
import Flag exposing (Flag)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Pages
import Pages.FB.Bookmark as FBBookmark
import Pages.FB.User as FBUser
import Pages.NewBookmark.PageInfo as PageInfo exposing (PageInfo)
import Session exposing (Session)
import Url



------ Model ------
{-
   type NewBookmarkCreatingStatus
       = NewBookmarkNotCreated
       | NewBookmarkCreating
       | NewBookmarkCreated (Result BookmarkCreatingError Bookmark)
-}


type alias Model =
    { flag : Flag
    , session : Session
    , pageInfo : PageInfo
    }



------ Msg ------


type Msg
    = SetUrl String
    | SetTitle String
    | SetDescription String
    | CreatesNewbookmark
    | CreatingNewBookmarkSucceeded FBBookmark.Bookmark
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
------ Update ------


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetUrl value ->
            ( { model | pageInfo = model.pageInfo |> PageInfo.mapUrl (Url.fromString value) }, Cmd.none )

        SetTitle value ->
            ( { model | pageInfo = model.pageInfo |> PageInfo.mapTitle (Title.new value) }, Cmd.none )

        SetDescription value ->
            ( { model | pageInfo = model.pageInfo |> PageInfo.mapDescription (Description.new value) }, Cmd.none )

        CreatesNewbookmark ->
            case ( model.session |> Session.toUserData, model.pageInfo |> PageInfo.toUrl ) of
                ( Just { currentUser }, Just url ) ->
                    ( model
                    , createsNewBookmark
                        ( { url = Url.toString url
                          , title = model.pageInfo |> PageInfo.toTitle |> Title.unwrap
                          , description = model.pageInfo |> PageInfo.toDescription |> Description.unwrap
                          }
                        , currentUser
                        )
                    )

                ( _, _ ) ->
                    ( model, Cmd.none )

        CreatingNewBookmarkSucceeded bookmark ->
            ( model, Cmd.none )

        CreatingNewBookmarkFailed error ->
            ( model, Cmd.none )

        StartFetchingPageInfo ->
            ( model, model.pageInfo |> PageInfo.fetchFromRemote model.flag PageInfoFetched )

        PageInfoFetched result ->
            case result of
                Ok pageInfo ->
                    ( { model | pageInfo = pageInfo }, Cmd.none )

                Err _ ->
                    -- TODO: エラーを出す
                    ( model, Cmd.none )



------ Init ------


init : Maybe Url.Url -> Title -> Description -> Flag -> Session -> Model
init url title description flag session =
    { flag = flag
    , session = session
    , pageInfo =
        PageInfo.fromUrl url
            |> PageInfo.mapTitle title
            |> PageInfo.mapDescription description
    }



------ View ------


view : Model -> Html Msg
view { pageInfo } =
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
                            , pageInfo |> PageInfo.toUrl |> Maybe.map Url.toString |> Maybe.withDefault "" |> value
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
                            , pageInfo |> PageInfo.toTitle |> Title.unwrap |> value
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
                            , pageInfo |> PageInfo.toDescription |> Description.unwrap |> value
                            , onInput SetDescription
                            ]
                            []
                        ]
                    ]
                , div []
                    [ div []
                        [ button
                            [ type_ "button", onClick StartFetchingPageInfo ]
                            [ text "fetch" ]
                        ]
                    , div []
                        [ button
                            [ type_ "submit" ]
                            [ text "create" ]
                        ]
                    ]
                ]
            ]
        ]



------ Subscription ------


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ creatingNewBookmarkSucceeded CreatingNewBookmarkSucceeded
        , creatingNewBookmarkFailed CreatingNewBookmarkFailed
        ]



------ Port ------


port createsNewBookmark : ( FBBookmark.Bookmark, FBUser.User ) -> Cmd msg


port creatingNewBookmarkSucceeded : (FBBookmark.Bookmark -> msg) -> Sub msg


port creatingNewBookmarkFailed : (String -> msg) -> Sub msg
