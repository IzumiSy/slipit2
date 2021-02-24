module User exposing
    ( User
    , decode
    , uid
    )

import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Typed exposing (Typed)


type alias Uid =
    Typed UidType String Typed.ReadOnly


type alias Email =
    Typed EmailType String Typed.ReadOnly


type alias DisplayName =
    Typed DisplayNameType String Typed.ReadOnly


{-| Userのデータ構造を表現した型

TODO: Firebase Authenticationのデータ構造と結合してるのでどうにかしたい

-}
type User
    = User
        { uid : Uid
        , email : Email
        , displayName : Maybe DisplayName
        }


uid : User -> Uid
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
        |> Pipeline.required "uid" (Typed.decode Decode.string)
        |> Pipeline.required "email" (Typed.decode Decode.string)
        |> Pipeline.optional "displayName" (Decode.map Just (Typed.decode Decode.string)) Nothing



-- internals


type UidType
    = UidType


type EmailType
    = EmailType


type DisplayNameType
    = DisplayNameType
