module Flag exposing
    ( Flag
    , decode
    , empty
    )

import Bookmarks
import Flag.Function as Function
import Flag.Logo as Logo
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline


type alias Flag =
    { function : Function.Function
    , logo : Logo.Logo
    , cachedBookmarks : Maybe Bookmarks.Bookmarks
    }


empty : Flag
empty =
    { function = Function.empty
    , logo = Logo.empty
    , cachedBookmarks = Nothing
    }



-- decoder


decode : Decode.Decoder Flag
decode =
    Decode.succeed Flag
        |> Pipeline.required "functionUrl" Function.decode
        |> Pipeline.required "logoImagePath" Logo.decode
        |> Pipeline.required "bookmarks" (Decode.nullable Bookmarks.decode)
