module Pages.SignIn.Error exposing
    ( Error
    , decoder
    , init
    , message
    )

import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Typed exposing (Typed)


type alias Code =
    Typed CodeType String Typed.ReadOnly


type alias Message =
    Typed MessageType String Typed.ReadOnly


type alias Payload =
    { code : Code
    , message : Message
    }


type Error
    = None
    | FBAuth Payload
    | Other Message


init : Error
init =
    None


message : Error -> Maybe Message
message error =
    case error of
        None ->
            Nothing

        Other msg ->
            Just msg

        FBAuth payload ->
            Just payload.message


decoder : Decode.Decoder Error
decoder =
    Decode.oneOf [ fbauthDecoder, otherDecoder ]



-- interals


type CodeType
    = CodeType


type MessageType
    = MessageType


fbauthDecoder : Decode.Decoder Error
fbauthDecoder =
    Decode.succeed Payload
        |> Pipeline.required "code" (Typed.decode Decode.string)
        |> Pipeline.required "message" (Typed.decode Decode.string)
        |> Decode.andThen (Decode.succeed << FBAuth)


otherDecoder : Decode.Decoder Error
otherDecoder =
    Decode.andThen (Decode.succeed << Other) (Typed.decode Decode.string)
