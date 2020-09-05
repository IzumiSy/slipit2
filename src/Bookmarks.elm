port module Bookmarks exposing
    ( Bookmarks
    , Ordered
    , decode
    , find
    , map
    , persistToCache
    , size
    , toListOrdered
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


toListOrdered : Bookmarks -> Ordered
toListOrdered (Bookmarks bookmarks) =
    Ordered <| Dict.values bookmarks


{-| 順序が保証されたList型のBookmarkを表現する型

Bookmarks型は内部実装をDictにすることで検索処理の計算量を下げているので
Viewにマッピングする際には明示的にtoListOrdered関数経由で敢えて順序があることを明示するようにしている

-}
type Ordered
    = Ordered (List Bookmark)


map : (Bookmark -> a) -> Ordered -> List a
map cb (Ordered bookmarks) =
    List.map cb bookmarks


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
