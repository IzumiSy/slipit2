module Bookmark exposing (Bookmark, fold, isValid, new)

import Bookmark.Description as Description exposing (Description)
import Bookmark.Title as Title exposing (Title)
import Url


type alias Id =
    String


type Bookmark
    = Valid Id Url.Url Title Description
    | Invalid Title Description


new : Id -> Maybe Url.Url -> Title -> Description -> Bookmark
new id maybeUrl title description =
    case maybeUrl of
        Just url ->
            Valid id url title description

        Nothing ->
            Invalid title description


type alias ValidCb =
    { url : Url.Url
    , title : Title
    , description : Description
    }


type alias InvalidCb =
    { title : Title
    , description : Description
    }


fold : (ValidCb -> a) -> (InvalidCb -> a) -> Bookmark -> a
fold validCb invalidCb bookmark =
    case bookmark of
        Valid id url title description ->
            validCb { url = url, title = title, description = description }

        Invalid title description ->
            invalidCb { title = title, description = description }


isValid : Bookmark -> Bool
isValid bookmark =
    case bookmark of
        Valid _ _ _ _ ->
            True

        Invalid _ _ ->
            False
