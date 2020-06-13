module User exposing
    ( User
    , decode
    , uid
    )

import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline



-- Userのデータ構造を表現した型
-- TODO: Firebase Authenticationのデータ構造と結合してるのでどうにかしたい


type User
    = User
        { uid : String
        , email : String
        , displayName : Maybe String
        }


uid : User -> String
uid (User user) =
    user.uid



-- decoder


decode : Decode.Decoder User
decode =
    Decode.succeed
        (\uid_ email displayName ->
            User
                { uid = uid_
                , email = email
                , displayName = displayName
                }
        )
        |> Pipeline.required "uid" Decode.string
        |> Pipeline.required "email" Decode.string
        |> Pipeline.optional "displayName" (Decode.map Just Decode.string) Nothing
