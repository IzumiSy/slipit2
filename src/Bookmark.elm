module Bookmark exposing
    ( Bookmark
    , decoder
    , description
    , title
    , url
    )

import Bookmark.Description as Description exposing (Description)
import Bookmark.Id as Id exposing (Id)
import Bookmark.Title as Title exposing (Title)
import Bookmark.Url as Url exposing (Url)
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline


type Bookmark
    = Bookmark Id Url Title Description


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
        |> Pipeline.required "id" Id.decode
        |> Pipeline.required "url" Url.decode
        |> Pipeline.required "title" Title.decode
        |> Pipeline.required "description" Description.decode
