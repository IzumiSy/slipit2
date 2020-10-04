port module Bookmarks exposing
    ( Bookmarks
    , decode
    , find
    , persistToCache
    , size
    , toList
    )

import Bookmark exposing (Bookmark)
import Bookmark.Url as Url
import Dict
import Json.Decode as Decode
import Json.Encode as Encode
import Pages.NewBookmark.Url as NewBookmarkUrl



-- Bookmarkのコレクションを表現する型


type alias Url =
    String


type Bookmarks
    = Bookmarks (Dict.Dict Url Bookmark)


size : Bookmarks -> Int
size (Bookmarks bookmarks) =
    Dict.size bookmarks


{-| 既存で同じURLが存在しているかをチェックする

Bookmark.Url型であると既存のブックマークの値を対象にしてしまうためNewBookmark.Url型を
あえて判別対象として取るようなインターフェイスとしている

-}
find : NewBookmarkUrl.Url -> Bookmarks -> Maybe Bookmark
find url (Bookmarks bookmarks) =
    Dict.get (NewBookmarkUrl.unwrap url) bookmarks


toList : Bookmarks -> List Bookmark
toList (Bookmarks bookmarks) =
    Dict.values bookmarks


{-| Cacheへの永続化インターフェイス
-}
persistToCache : Bookmarks -> Cmd msg
persistToCache (Bookmarks bookmarks) =
    bookmarks
        |> Dict.values
        |> Encode.list Bookmark.encoder
        |> persistToCacheInternal



-- encoder


decode : Decode.Decoder Bookmarks
decode =
    Bookmark.decoder
        |> Decode.list
        |> Decode.andThen
            (Decode.succeed
                << Bookmarks
                << Dict.fromList
                << List.map (\bookmark -> ( Url.unwrap <| Bookmark.url bookmark, bookmark ))
            )



-- ports


port persistToCacheInternal : Encode.Value -> Cmd msg
