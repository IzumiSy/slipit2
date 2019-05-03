module Bookmark exposing (Bookmark, new, toDescription, toTitle, toUrl)

import Bookmark.Description as Description exposing (Description)
import Bookmark.Title as Title exposing (Title)
import Bookmark.Url as Url exposing (Url)


type Bookmark
    = Bookmark Url Title Description


new : Url -> Title -> Description -> Bookmark
new url title description =
    Bookmark url title description


toUrl : Bookmark -> Url
toUrl (Bookmark url _ _) =
    url


toTitle : Bookmark -> Title
toTitle (Bookmark _ title _) =
    title


toDescription : Bookmark -> Description
toDescription (Bookmark _ _ description) =
    description
