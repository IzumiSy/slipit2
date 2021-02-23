module Bookmark exposing
    ( Bookmark
    , decoder
    , description
    , encoder
    , title
    , url
    )

import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Json.Encode as Encode
import Typed exposing (Typed)


type alias Id =
    Typed IdType String Typed.ReadOnly


type alias Url =
    Typed UrlType String Typed.ReadOnly


type alias Title =
    Typed TitleType String Typed.ReadOnly


type alias Description =
    Typed DescriptionType String Typed.ReadOnly


type Bookmark
    = Bookmark Id Url Title Description


title : Bookmark -> Title
title (Bookmark _ _ value _) =
    value


description : Bookmark -> Description
description (Bookmark _ _ _ value) =
    value


url : Bookmark -> Url
url (Bookmark _ value _ _) =
    value



-- decoder


decoder : Decode.Decoder Bookmark
decoder =
    Decode.succeed Bookmark
        |> Pipeline.required "id" (Typed.decode Decode.string)
        |> Pipeline.required "url" (Typed.decode Decode.string)
        |> Pipeline.required "title" (Typed.decode Decode.string)
        |> Pipeline.required "description" (Typed.decode Decode.string)


encoder : Bookmark -> Encode.Value
encoder (Bookmark id url_ title_ description_) =
    Encode.object
        [ ( "id", Typed.encode Encode.string id )
        , ( "url", Typed.encode Encode.string url_ )
        , ( "title", Typed.encode Encode.string title_ )
        , ( "description", Typed.encode Encode.string description_ )
        ]



-- internals


type IdType
    = IdType


type UrlType
    = UrlType


type TitleType
    = TitleType


type DescriptionType
    = DescriptionType
