module Bookmark exposing
    ( Bookmark
    , Id
    , decoder
    , description
    , title
    , url
    )

import Bookmark.Description as Description exposing (Description)
import Bookmark.Title as Title exposing (Title)
import Bookmark.Url as Url
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline


type alias Id =
    String


type Bookmark
    = Bookmark Id Url.Url Title Description


title : Bookmark -> Title
title (Bookmark _ _ value _) =
    value


description : Bookmark -> Description
description (Bookmark _ _ _ value) =
    value


url : Bookmark -> Url.Url
url (Bookmark _ value _ _) =
    value



-- decoder


decoder : Decode.Decoder Bookmark
decoder =
    Decode.succeed Bookmark
        |> Pipeline.required "id" Decode.string
        |> Pipeline.required "url" Url.decode
        |> Pipeline.required "title" Title.decode
        |> Pipeline.required "description" Description.decode
