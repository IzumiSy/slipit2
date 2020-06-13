module Pages.NewBookmark.PageInfo exposing
    ( PageInfo
    , fetch
    , fromUrl
    , mapDescription
    , mapTitle
    , mapUrl
    , toDescription
    , toTitle
    , toUrl
    )

import App.Model as Model
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Pages.NewBookmark.Description as Description exposing (Description)
import Pages.NewBookmark.Title as Title exposing (Title)
import Pages.NewBookmark.Url as Url exposing (Url)
import String.Interpolate exposing (interpolate)


type PageInfo
    = PageInfo
        { url : Url
        , title : Title
        , description : Description
        }


fromUrl : Url -> PageInfo
fromUrl url =
    PageInfo
        { url = url
        , title = Title.empty
        , description = Description.empty
        }


mapUrl : Url -> PageInfo -> PageInfo
mapUrl url (PageInfo { title, description }) =
    PageInfo
        { url = url
        , title = title
        , description = description
        }


mapTitle : Title -> PageInfo -> PageInfo
mapTitle newTitle (PageInfo { url, description }) =
    PageInfo
        { url = url
        , title = newTitle
        , description = description
        }


mapDescription : Description -> PageInfo -> PageInfo
mapDescription newDescription (PageInfo { url, title }) =
    PageInfo
        { url = url
        , title = title
        , description = newDescription
        }


toUrl : PageInfo -> Url
toUrl (PageInfo { url }) =
    url


toTitle : PageInfo -> Title
toTitle (PageInfo { title }) =
    title


toDescription : PageInfo -> Description
toDescription (PageInfo { description }) =
    description


fetch : Model.Flag -> (Result Http.Error PageInfo -> msg) -> PageInfo -> Cmd msg
fetch { functionUrl } msg (PageInfo { url }) =
    Http.get
        { url = interpolate "{0}?url={1}" [ functionUrl, Url.unwrap url ]
        , expect =
            Http.expectJson
                msg
                (Decode.succeed
                    (\title description ->
                        Decode.succeed
                            (PageInfo
                                { url = url
                                , title = title
                                , description = description
                                }
                            )
                    )
                    |> Pipeline.required "title" Title.decode
                    |> Pipeline.required "description" Description.decode
                    |> Pipeline.resolve
                )
        }
